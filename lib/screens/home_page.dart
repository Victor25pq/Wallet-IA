import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart'; // Importante para detectar la dirección del scroll
import 'package:intl/intl.dart';
import '../models/finance_models.dart';
import 'add_transaction_page.dart';
import '/data/mock_data.dart';
import '../widgets/transaction_list.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // --- ESTADO Y DATOS ---
  final List<Account> _accounts = mockAccounts;
  final List<Transaction> _allTransactions = mockTransactions;
  final Account _allAccounts = const Account(
    id: 'all',
    name: 'Total Balance',
    balance: 0,
    icon: Icons.all_inclusive,
  );

  late Account _selectedAccount;
  late double _totalBalance;

  // --- NUEVOS ELEMENTOS PARA EL SCROLL Y LA VISIBILIDAD DEL FAB ---
  late ScrollController _scrollController;
  bool _isFabVisible = true;
  // --- FIN DE NUEVOS ELEMENTOS ---

  @override
  void initState() {
    super.initState();
    _selectedAccount = _allAccounts;
    _totalBalance = _accounts.fold(0, (sum, account) => sum + account.balance);

    // --- INICIALIZAMOS EL SCROLL CONTROLLER Y AÑADIMOS EL LISTENER ---
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      // Si el usuario está deslizando hacia abajo (reverse), ocultamos el FAB
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (_isFabVisible) {
          setState(() {
            _isFabVisible = false;
          });
        }
      }
      // Si el usuario está deslizando hacia arriba (forward), mostramos el FAB
      else if (_scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (!_isFabVisible) {
          setState(() {
            _isFabVisible = true;
          });
        }
      }
    });
    // --- FIN DE LA INICIALIZACIÓN ---
  }

  // --- ES BUENA PRÁCTICA LIBERAR LOS RECURSOS DEL CONTROLLER ---
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  // --- FIN DE DISPOSE ---

  void _onAccountSelected(Account account) {
    setState(() {
      _selectedAccount = account;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Transaction> displayedTransactions = _selectedAccount.id == 'all'
        ? _allTransactions
        : _allTransactions
              .where((tx) => tx.accountId == _selectedAccount.id)
              .toList();

    final balanceToShow = _selectedAccount.id == 'all'
        ? _totalBalance
        : _selectedAccount.balance;

    // --- 1. AÑADIMOS EL SCAFFOLD Y EL FLOATING ACTION BUTTON ---
    return Scaffold(
      body: SafeArea(
        child: ListView(
          // --- 2. ASOCIAMOS EL CONTROLLER CON EL LISTVIEW ---
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          children: [
            const SizedBox(height: 20),
            const _HomeHeader(),
            const SizedBox(height: 30),
            _BalanceCard(
              balance: balanceToShow,
              accounts: _accounts,
              allAccountsOption: _allAccounts,
              onAccountSelected: _onAccountSelected,
              selectedAccount: _selectedAccount,
            ),
            const SizedBox(height: 30),
            // --- 3. LA FILA DE BOTONES AHORA TIENE MENOS ELEMENTOS ---
            const _ActionButtonsRow(),
            const SizedBox(height: 30),
            _TransactionSection(transactions: displayedTransactions),
            const SizedBox(height: 20), // Un poco de espacio al final
          ],
        ),
      ),
      // --- 4. DEFINIMOS LOS BOTONES FLOTANTES Y SU ANIMACIÓN ---
      floatingActionButton: AnimatedSlide(
        duration: const Duration(milliseconds: 300),
        offset: _isFabVisible ? Offset.zero : const Offset(0, 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton(
              heroTag: 'fab_camera', // Tag único para el primer FAB
              onPressed: () => print('Abrir cámara presionado'),
              child: const Icon(Icons.camera_alt_rounded),
            ),
            const SizedBox(height: 12),
            FloatingActionButton(
              heroTag: 'fab_file', // Tag único para el segundo FAB
              onPressed: () => print('Abrir archivos presionado'),
              child: const Icon(Icons.file_upload_rounded),
            ),
          ],
        ),
      ),
    );
  }
}
// --- WIDGETS COMPONENTES DE LA PÁGINA ---

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Victor Angel',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              DateFormat.yMMMMd(
                'es_ES',
              ).format(DateTime.now()), // Fecha formateada
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
        CircleAvatar(
          radius: 30,
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Icon(
            Icons.person_outline,
            size: 35,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ],
    );
  }
}

class _BalanceCard extends StatefulWidget {
  final double balance;
  final List<Account> accounts;
  final Account allAccountsOption;
  final Function(Account) onAccountSelected;
  final Account selectedAccount;

  const _BalanceCard({
    required this.balance,
    required this.accounts,
    required this.allAccountsOption,
    required this.onAccountSelected,
    required this.selectedAccount,
  });

  @override
  State<_BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<_BalanceCard> {
  bool _isBalanceVisible = true;

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'en_US',
      symbol: '\$',
    );

    return Container(
      padding: const EdgeInsets.all(25.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PopupMenuButton<Account>(
            onSelected: widget.onAccountSelected,
            itemBuilder: (context) {
              final allAccountsOption = [
                PopupMenuItem<Account>(
                  value: widget.allAccountsOption,
                  child: Text(
                    widget.allAccountsOption.name,
                    style: TextStyle(
                      fontWeight:
                          widget.selectedAccount.id ==
                              widget.allAccountsOption.id
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ];

              final accountOptions = widget.accounts.map((account) {
                final bool isSelected = widget.selectedAccount.id == account.id;
                return PopupMenuItem<Account>(
                  value: account,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        account.name,
                        style: TextStyle(
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      Text(
                        currencyFormatter.format(account.balance),
                        style: TextStyle(
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList();
              return allAccountsOption + accountOptions;
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.selectedAccount.name,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                _isBalanceVisible
                    ? currencyFormatter.format(widget.balance)
                    : '••••••••••',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isBalanceVisible = !_isBalanceVisible;
                  });
                },
                child: Icon(
                  _isBalanceVisible
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// --- ESTE WIDGET AHORA ESTÁ MODIFICADO ---
class _ActionButtonsRow extends StatelessWidget {
  const _ActionButtonsRow();

  @override
  Widget build(BuildContext context) {
    // 1. Usamos SingleChildScrollView para permitir el deslizamiento
    return SingleChildScrollView(
      // 2. Le decimos que la dirección del scroll es horizontal
      scrollDirection: Axis.horizontal,
      // 3. Dentro, ponemos una Row normal con nuestros botones
      child: Row(
        children: [
          _ActionButton(
            icon: Icons.arrow_upward_rounded,
            label: 'Ingreso',
            color: Colors.green.shade700,
            onTap: () {
              Navigator.pushNamed(
                context,
                '/add_transaction',
                arguments: TransactionType.ingreso,
              );
            },
          ),
          // 4. Añadimos un espacio fijo entre los botones
          const SizedBox(width: 12),
          _ActionButton(
            icon: Icons.arrow_downward_rounded,
            label: 'Gasto',
            color: Colors.red.shade600,
            onTap: () {
              Navigator.pushNamed(
                context,
                '/add_transaction',
                arguments: TransactionType.gasto,
              );
            },
          ),
          const SizedBox(width: 12),
          _ActionButton(
            icon: Icons.swap_horiz,
            label: 'Transferir',
            onTap: () {
              Navigator.pushNamed(context, '/transfer');
            },
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    // Volvemos a la lógica de color simple
    final buttonColor = color ?? Theme.of(context).primaryColor;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: buttonColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        // La fila para el ícono y el texto
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: buttonColor),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: buttonColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionSection extends StatelessWidget {
  final List<Transaction> transactions;
  const _TransactionSection({required this.transactions});

  @override
  Widget build(BuildContext context) {
    final recentTransactions = transactions.take(3).toList();

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Transaction',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/all_transactions');
                },
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (recentTransactions.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0),
              child: Center(
                child: Text('No hay transacciones para esta cuenta.'),
              ),
            )
          else
            TransactionList(transactions: recentTransactions),
        ],
      ),
    );
  }
}
