// lib/screens/home_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:login_app/models/finance_models.dart';
import 'package:login_app/services/supabase_service.dart';

import 'package:login_app/widgets/home/balance_card.dart';
import 'package:login_app/widgets/home/home_header.dart';
import 'package:login_app/widgets/home/action_buttons_row.dart';
import 'package:login_app/widgets/home/transaction_section.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SupabaseService _supabaseService = SupabaseService();
  // Ahora el Future cargará una lista de resultados (billeteras y transacciones)
  late Future<List<dynamic>> _dataFuture;

  final Account _allAccountsPlaceholder = const Account(
    id: 'all',
    name: 'Total Balance',
    balance: 0,
    icon: Icons.all_inclusive,
    currency: 'USD',
  );
  late Account _selectedAccount;

  late ScrollController _scrollController;
  bool _isFabVisible = true;

  @override
  void initState() {
    super.initState();
    _selectedAccount = _allAccountsPlaceholder;
    _dataFuture = _loadData(); // Carga inicial

    _scrollController = ScrollController();
    _scrollController.addListener(() {
      final direction = _scrollController.position.userScrollDirection;
      if (direction == ScrollDirection.reverse && _isFabVisible) {
        setState(() => _isFabVisible = false);
      } else if (direction == ScrollDirection.forward && !_isFabVisible) {
        setState(() => _isFabVisible = true);
      }
    });
  }

  // Función que carga todos los datos necesarios
  Future<List<dynamic>> _loadData() {
    return Future.wait([
      _supabaseService.getWallets(),
      _supabaseService.getTransactions(),
    ]);
  }

  // Función para refrescar los datos
  void _refreshData() {
    setState(() {
      _dataFuture = _loadData();
    });
  }

  // --- NUEVO: Lógica para calcular el balance real ---
  List<Account> _calculateRealBalances(
    List<Account> wallets,
    List<Transaction> transactions,
  ) {
    Map<String, double> balanceDeltas = {};

    // Calculamos los cambios de balance por cada billetera
    for (var transaction in transactions) {
      final amount = transaction.status == TransactionStatus.Ingreso
          ? transaction.amount
          : -transaction.amount;
      balanceDeltas.update(
        transaction.walletId,
        (value) => value + amount,
        ifAbsent: () => amount,
      );
    }

    // Creamos una nueva lista de billeteras con los balances actualizados
    List<Account> updatedWallets = [];
    for (var wallet in wallets) {
      final newBalance = wallet.balance + (balanceDeltas[wallet.id] ?? 0);
      updatedWallets.add(
        Account(
          id: wallet.id,
          name: wallet.name,
          balance: newBalance,
          icon: wallet.icon,
          currency: wallet.currency,
        ),
      );
    }
    return updatedWallets;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onAccountSelected(Account account) {
    setState(() {
      _selectedAccount = account;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<List<dynamic>>(
          future: _dataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (snapshot.hasData) {
              final wallets = snapshot.data![0] as List<Account>;
              final transactions = snapshot.data![1] as List<Transaction>;

              // Calculamos los balances reales
              final updatedWallets = _calculateRealBalances(
                wallets,
                transactions,
              );

              // Calculamos el balance total
              final totalBalance = updatedWallets.fold(
                0.0,
                (sum, account) => sum + account.balance,
              );

              // Determinamos qué balance mostrar
              final balanceToShow = _selectedAccount.id == 'all'
                  ? totalBalance
                  : updatedWallets
                        .firstWhere(
                          (w) => w.id == _selectedAccount.id,
                          orElse: () => _selectedAccount,
                        )
                        .balance;

              return ListView(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                children: [
                  const SizedBox(height: 20),
                  const HomeHeader(),
                  const SizedBox(height: 30),
                  BalanceCard(
                    balance: balanceToShow,
                    accounts: updatedWallets,
                    allAccountsOption: _allAccountsPlaceholder,
                    onAccountSelected: _onAccountSelected,
                    selectedAccount: _selectedAccount.id == 'all'
                        ? _allAccountsPlaceholder
                        : updatedWallets.firstWhere(
                            (w) => w.id == _selectedAccount.id,
                          ),
                  ),
                  const SizedBox(height: 30),
                  ActionButtonsRow(
                    selectedAccount: _selectedAccount,
                    onTransactionSaved:
                        _refreshData, // Pasamos la función de refresco
                  ),
                  const SizedBox(height: 30),
                  TransactionSection(
                    transactions: transactions,
                  ), // Mostramos las transacciones
                  const SizedBox(height: 20),
                ],
              );
            }

            return const Center(child: Text('Iniciando...'));
          },
        ),
      ),
      floatingActionButton: AnimatedSlide(
        duration: const Duration(milliseconds: 300),
        offset: _isFabVisible ? Offset.zero : const Offset(0, 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton(
              heroTag: 'fab_camera',
              onPressed: () => print('Abrir cámara presionado'),
              child: const Icon(Icons.camera_alt_rounded),
            ),
            const SizedBox(height: 12),
            FloatingActionButton(
              heroTag: 'fab_file',
              onPressed: () => print('Abrir archivos presionado'),
              child: const Icon(Icons.file_upload_rounded),
            ),
          ],
        ),
      ),
    );
  }
}
