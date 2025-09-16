// lib/screens/home_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:login_app/models/finance_models.dart';
import 'package:login_app/services/supabase_service.dart';

//Widgets creados
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
  // Creamos una instancia de nuestro servicio
  final SupabaseService _supabaseService = SupabaseService();
  // Este Future contendrá los datos de la base de datos
  late Future<List<Account>> _walletsFuture;

  // Los demás estados se mantienen igual
  final Account _allAccounts = const Account(
    id: 'all',
    name: 'Total Balance',
    balance: 0,
    icon: Icons.all_inclusive,
  );
  late Account _selectedAccount;
  late double _totalBalance;
  late ScrollController _scrollController;
  bool _isFabVisible = true;

  @override
  void initState() {
    super.initState();
    // En lugar de usar datos mock, llamamos a nuestro servicio.
    // El FutureBuilder se encargará del resto.
    _walletsFuture = _supabaseService.getWallets();

    _selectedAccount = _allAccounts;
    _totalBalance = 0; // Se calculará cuando los datos lleguen

    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (_isFabVisible) setState(() => _isFabVisible = false);
      } else if (_scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (!_isFabVisible) setState(() => _isFabVisible = true);
      }
    });
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
        // USAMOS FUTUREBUILDER PARA MANEJAR LA CARGA DE DATOS
        child: FutureBuilder<List<Account>>(
          future: _walletsFuture,
          builder: (context, snapshot) {
            // ESTADO 1: Cargando...
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // ESTADO 2: Error
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            // ESTADO 3: Datos recibidos correctamente
            if (snapshot.hasData) {
              final accounts = snapshot.data!;
              _totalBalance = accounts.fold(
                0,
                (sum, account) => sum + account.balance,
              );

              // Aquí va la UI que ya tenías, pero usando los datos reales 'accounts'
              final balanceToShow = _selectedAccount.id == 'all'
                  ? _totalBalance
                  : _selectedAccount.balance;

              // En un futuro, aquí también cargaríamos las transacciones
              final displayedTransactions = <Transaction>[];

              return ListView(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                children: [
                  const SizedBox(height: 20),
                  const HomeHeader(),
                  const SizedBox(height: 30),
                  BalanceCard(
                    balance: balanceToShow,
                    accounts: accounts, // Pasamos las cuentas reales
                    allAccountsOption: _allAccounts,
                    onAccountSelected: _onAccountSelected,
                    selectedAccount: _selectedAccount,
                  ),
                  const SizedBox(height: 30),
                  const ActionButtonsRow(),
                  const SizedBox(height: 30),
                  TransactionSection(transactions: displayedTransactions),
                  const SizedBox(height: 20),
                ],
              );
            }

            // Estado por defecto (no debería llegar aquí)
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
