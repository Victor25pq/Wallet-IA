// lib/screens/settings_page.dart

import 'package:flutter/material.dart';
import 'package:login_app/models/finance_models.dart';
import 'package:login_app/services/supabase_service.dart';
import 'package:login_app/widgets/settings/add_category_form.dart';
import 'package:login_app/widgets/settings/add_wallet_form.dart';
import 'package:login_app/widgets/settings/collapsible_section.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final SupabaseService _supabaseService = SupabaseService();

  List<Account> _wallets = [];
  List<Category> _categories = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final results = await Future.wait([
        _supabaseService.getWallets(),
        _supabaseService.getCategories(),
      ]);
      if (mounted) {
        setState(() {
          _wallets = results[0] as List<Account>;
          _categories = results[1] as List<Category>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = "Error al cargar los datos: $e";
          _isLoading = false;
        });
      }
    }
  }

  void _showAddWalletForm() {
    showModalBottomSheet<Account>(
      context: context,
      isScrollControlled: true,
      builder: (context) => const AddWalletForm(),
    ).then((newWallet) {
      if (newWallet != null) {
        setState(() => _wallets.add(newWallet));
      }
    });
  }

  void _showEditWalletForm(Account walletToEdit) {
    showModalBottomSheet<Account>(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddWalletForm(walletToEdit: walletToEdit),
    ).then((updatedWallet) {
      if (updatedWallet != null) {
        setState(() {
          final index = _wallets.indexWhere((w) => w.id == updatedWallet.id);
          if (index != -1) {
            _wallets[index] = updatedWallet;
          }
        });
      }
    });
  }

  void _showAddCategoryForm() {
    showModalBottomSheet<Category>(
      context: context,
      isScrollControlled: true,
      builder: (context) => const AddCategoryForm(),
    ).then((newCategory) {
      if (newCategory != null) {
        setState(() {
          _categories.add(newCategory);
          _categories.sort((a, b) => a.title.compareTo(b.title));
        });
      }
    });
  }

  void _showEditCategoryForm(Category categoryToEdit) {
    showModalBottomSheet<Category>(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddCategoryForm(categoryToEdit: categoryToEdit),
    ).then((updatedCategory) {
      if (updatedCategory != null) {
        setState(() {
          final index = _categories.indexWhere(
            (c) => c.id == updatedCategory.id,
          );
          if (index != -1) {
            _categories[index] = updatedCategory;
            _categories.sort((a, b) => a.title.compareTo(b.title));
          }
        });
      }
    });
  }

  Future<void> _handleDeleteWallet(Account wallet) async {
    final index = _wallets.indexOf(wallet);
    setState(() => _wallets.remove(wallet));

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context)
        .showSnackBar(
          SnackBar(
            content: Text('${wallet.name} eliminada'),
            action: SnackBarAction(
              label: 'Deshacer',
              onPressed: () {
                setState(() => _wallets.insert(index, wallet));
              },
            ),
          ),
        )
        .closed
        .then((reason) {
          if (reason != SnackBarClosedReason.action) {
            _supabaseService.deleteWallet(wallet.id).catchError((error) {
              if (mounted) {
                setState(() => _wallets.insert(index, wallet));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error al eliminar la billetera: $error'),
                  ),
                );
              }
            });
          }
        });
  }

  Future<void> _handleDeleteCategory(Category category) async {
    final index = _categories.indexOf(category);
    setState(() => _categories.remove(category));

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context)
        .showSnackBar(
          SnackBar(
            content: Text('${category.title} eliminada'),
            action: SnackBarAction(
              label: 'Deshacer',
              onPressed: () {
                setState(() => _categories.insert(index, category));
              },
            ),
          ),
        )
        .closed
        .then((reason) {
          if (reason != SnackBarClosedReason.action) {
            _supabaseService.deleteCategory(category.id).catchError((error) {
              if (mounted) {
                setState(() => _categories.insert(index, category));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error al eliminar la categoría: $error'),
                  ),
                );
              }
            });
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Configuración'),
        elevation: 0,
        backgroundColor: Colors.grey[100],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text(_error!));
    }
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildWalletsSection(_wallets),
        _buildCategoriesSection(_categories),
      ],
    );
  }

  Widget _buildWalletsSection(List<Account> wallets) {
    return CollapsibleSection(
      title: 'Billeteras',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...wallets.map(
            (wallet) => Dismissible(
              key: ValueKey(wallet.id),
              direction: DismissDirection.endToStart,
              onDismissed: (_) => _handleDeleteWallet(wallet),
              background: _buildDeleteBackground(),
              // ENVOLVEMOS EL LISTTILE EN UN GESTUREDETECTOR
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _showEditWalletForm(wallet),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    wallet.icon,
                    color: Theme.of(context).primaryColor,
                  ),
                  title: Text(wallet.name),
                ),
              ),
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.add, color: Colors.blue),
            title: const Text('Añadir', style: TextStyle(color: Colors.blue)),
            onTap: _showAddWalletForm,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesSection(List<Category> categories) {
    return CollapsibleSection(
      title: 'Categorías',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: categories.map((category) {
              return Dismissible(
                key: ValueKey(category.id),
                resizeDuration: null,
                direction: DismissDirection.endToStart,
                onDismissed: (_) => _handleDeleteCategory(category),
                background: _buildDeleteBackground(isChip: true),
                child: InkWell(
                  onTap: () => _showEditCategoryForm(category),
                  borderRadius: BorderRadius.circular(50),
                  child: _CategoryChip(category: category),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.add, color: Colors.blue),
            title: const Text('Añadir', style: TextStyle(color: Colors.blue)),
            onTap: _showAddCategoryForm,
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteBackground({bool isChip = false}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(isChip ? 50 : 4),
      child: Container(
        decoration: BoxDecoration(color: Colors.red.shade700),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final Category category;
  const _CategoryChip({required this.category});

  @override
  Widget build(BuildContext context) {
    final bool isExpense = category.type == 'gasto';
    final Color color = isExpense ? Colors.red.shade400 : Colors.green.shade600;
    return Chip(
      avatar: Icon(category.icon, color: color, size: 20),
      label: Text(category.title),
      backgroundColor: color.withOpacity(0.1),
      shape: StadiumBorder(side: BorderSide(color: color.withOpacity(0.2))),
    );
  }
}
