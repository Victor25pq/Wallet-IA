// lib/screens/add_transaction_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login_app/services/supabase_service.dart';
import 'package:login_app/widgets/settings/add_category_form.dart';
import '../models/finance_models.dart';
import '../utils/account_selector.dart';

class AddTransactionPage extends StatefulWidget {
  final TransactionType type;
  final Transaction? transaction;
  final Account? preselectedAccount;

  const AddTransactionPage({
    super.key,
    required this.type,
    this.transaction,
    this.preselectedAccount,
  });
  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _supabaseService = SupabaseService();

  Account? _selectedAccount;
  DateTime _selectedDate = DateTime.now();
  int? _selectedCategoryIndex;

  List<Category> _availableCategories = [];
  bool _isLoadingCategories = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    if (!mounted) return;
    setState(() => _isLoadingCategories = true);

    final allCategories = await _supabaseService.getCategories();
    if (!mounted) return;

    final categoryTypeString = widget.type == TransactionType.ingreso
        ? 'ingreso'
        : 'gasto';
    _availableCategories = allCategories
        .where((cat) => cat.type == categoryTypeString)
        .toList();

    if (widget.preselectedAccount != null &&
        widget.preselectedAccount!.id != 'all') {
      _selectedAccount = widget.preselectedAccount;
    }

    if (widget.transaction != null) {
      if (_amountController.text.isEmpty) {
        final allAccounts = await _supabaseService.getWallets();
        _amountController.text = widget.transaction!.amount.toString();
        _descriptionController.text = widget.transaction!.title;
        // CAMBIADO
        _selectedAccount = allAccounts.firstWhere(
          (acc) => acc.id == widget.transaction!.walletId,
        );
        _selectedDate = widget.transaction!.date;
      }
      _selectedCategoryIndex = _availableCategories.indexWhere(
        (cat) => cat.id == widget.transaction!.categoryId,
      );
      if (_selectedCategoryIndex == -1) _selectedCategoryIndex = null;
    }

    setState(() => _isLoadingCategories = false);
  }

  // ... (El resto de la página se mantiene igual)

  Future<void> _openCategoryForm({Category? categoryToEdit}) async {
    await showModalBottomSheet<Category>(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddCategoryForm(
        categoryToEdit: categoryToEdit,
        preselectedType: categoryToEdit == null ? widget.type : null,
      ),
    );
    _initializeData();
  }

  void _showCategoryActions(Category category) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Wrap(
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Editar'),
            onTap: () {
              Navigator.pop(context);
              _openCategoryForm(categoryToEdit: category);
            },
          ),
          ListTile(
            leading: Icon(Icons.delete, color: Colors.red.shade700),
            title: Text(
              'Eliminar',
              style: TextStyle(color: Colors.red.shade700),
            ),
            onTap: () {
              Navigator.pop(context);
              _handleDeleteCategory(category);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _handleDeleteCategory(Category category) async {
    final index = _availableCategories.indexOf(category);
    setState(() => _availableCategories.remove(category));
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context)
        .showSnackBar(
          SnackBar(
            content: Text('${category.title} eliminada'),
            action: SnackBarAction(
              label: 'Deshacer',
              onPressed: () =>
                  setState(() => _availableCategories.insert(index, category)),
            ),
          ),
        )
        .closed
        .then((reason) {
          if (reason != SnackBarClosedReason.action) {
            _supabaseService.deleteCategory(category.id).catchError((error) {
              if (mounted) {
                setState(() => _availableCategories.insert(index, category));
              }
            });
          }
        });
  }

  Future<void> _selectAccount() async {
    final accounts = await _supabaseService.getWallets();
    if (!mounted) return;
    final account = await showAccountSelector(context, accounts);
    if (account != null) setState(() => _selectedAccount = account);
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate)
      setState(() => _selectedDate = picked);
  }

  Future<void> _saveTransaction() async {
    if (_amountController.text.isEmpty ||
        _selectedCategoryIndex == null ||
        _selectedAccount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, completa todos los campos')),
      );
      return;
    }
    setState(() => _isSaving = true);
    try {
      final amount = double.parse(_amountController.text);
      final type = widget.type == TransactionType.ingreso ? 'ingreso' : 'gasto';
      final categoryId = _availableCategories[_selectedCategoryIndex!].id;
      final accountId = _selectedAccount!.id;
      final description = _descriptionController.text;

      if (widget.transaction == null) {
        await _supabaseService.addTransaction(
          amount: amount,
          type: type,
          categoryId: categoryId,
          accountId: accountId,
          description: description,
          date: _selectedDate,
        );
      } else {
        await _supabaseService.updateTransaction(
          id: widget.transaction!.id,
          amount: amount,
          type: type,
          categoryId: categoryId,
          accountId: accountId,
          description: description,
          date: _selectedDate,
        );
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.type == TransactionType.ingreso
        ? 'Añadir Ingreso'
        : 'Añadir Gasto';

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isSaving ? null : _saveTransaction,
        label: _isSaving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Guardar',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
        icon: _isSaving
            ? const SizedBox()
            : const Icon(Icons.check, color: Colors.white),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 80.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextFormField(
                controller: _amountController,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: '0.00',
                  hintStyle: TextStyle(color: Colors.grey.shade300),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(top: 1.0),
                    child: Text(
                      '\$',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      double.tryParse(value) == null ||
                      double.parse(value) <= 0) {
                    return 'Ingresa un monto válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  children: [
                    const Text(
                      'Categoría',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    _isLoadingCategories
                        ? const Center(child: CircularProgressIndicator())
                        : _CategorySelector(
                            categories: _availableCategories,
                            initialIndex: _selectedCategoryIndex,
                            onCategorySelected: (index) =>
                                setState(() => _selectedCategoryIndex = index),
                            onAddTapped: () => _openCategoryForm(),
                            onCategoryLongPress: (category) =>
                                _showCategoryActions(category),
                          ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        icon: Icon(Icons.description_outlined),
                        labelText: 'Descripción (Opcional)',
                      ),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.account_balance_wallet_outlined,
                      ),
                      title: const Text('Cuenta'),
                      subtitle: Text(
                        _selectedAccount?.name ?? 'Seleccionar cuenta',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: _selectAccount,
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.calendar_today_outlined),
                      title: const Text('Fecha'),
                      subtitle: Text(
                        DateFormat.yMMMMd('es_ES').format(_selectedDate),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: _selectDate,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ... Widgets internos se mantienen igual ...
class _CategorySelector extends StatelessWidget {
  final List<Category> categories;
  final int? initialIndex;
  final Function(int) onCategorySelected;
  final VoidCallback onAddTapped;
  final Function(Category) onCategoryLongPress;
  const _CategorySelector({
    required this.categories,
    required this.initialIndex,
    required this.onCategorySelected,
    required this.onAddTapped,
    required this.onCategoryLongPress,
  });
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length + 1,
        itemBuilder: (context, index) {
          if (index == categories.length) {
            return _AddCategoryButton(onTap: onAddTapped);
          }
          final category = categories[index];
          final bool isSelected = initialIndex == index;
          return InkWell(
            onTap: () => onCategorySelected(index),
            onLongPress: () => onCategoryLongPress(category),
            borderRadius: BorderRadius.circular(12),
            child: _CategoryChip(category: category, isSelected: isSelected),
          );
        },
        separatorBuilder: (context, index) => const SizedBox(width: 10),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.category, required this.isSelected});
  final Category category;
  final bool isSelected;
  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).primaryColor;
    return SizedBox(
      width: 70,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: isSelected
                ? color.withOpacity(0.2)
                : Colors.grey[200],
            child: Icon(
              category.icon,
              color: isSelected ? color : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            category.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? color : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}

class _AddCategoryButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddCategoryButton({required this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 70,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: Colors.grey[200],
              child: Icon(Icons.add, color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Text(
              'Añadir',
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }
}
