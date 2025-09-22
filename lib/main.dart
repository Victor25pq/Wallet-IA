// lib/main.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:login_app/models/finance_models.dart';
import 'package:login_app/screens/main_screen.dart';
import 'package:login_app/screens/splash_page.dart';
import 'package:login_app/screens/transfer_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/login_page.dart';
import 'screens/add_transaction_page.dart';
import 'screens/all_transactions_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_ES', null);

  await Supabase.initialize(
    url: 'https://icwmnzbkpezpddwqgbbs.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imljd21uemJrcGV6cGRkd3FnYmJzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5NTQ1MDIsImV4cCI6MjA3MzUzMDUwMn0.f1N7JXkWVT54bTECJA8PDO9IbtJMUHvp7QFU2XwrLkA',
  );

  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription<AuthState>? _authStateSubscription;

  @override
  void initState() {
    super.initState();
    _setupAuthListener();
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }

  void _setupAuthListener() {
    _authStateSubscription = supabase.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      final navigator = Navigator.of(context);
      if (session != null) {
        // Si hay una sesión, vamos a la pantalla principal
        navigator.pushReplacementNamed('/home');
      } else {
        // Si no hay sesión, vamos a la pantalla de login
        navigator.pushReplacementNamed('/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WalletIA',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashPage(),
        '/login': (context) => const LoginPage(),
        '/home': (context) => const MainScreen(),
        '/add_transaction': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>;
          final type = args['type'] as TransactionType;
          final account = args['account'] as Account?;

          return AddTransactionPage(type: type, preselectedAccount: account);
        },
        '/transfer': (context) => const TransferPage(),
        '/all_transactions': (context) => const AllTransactionsPage(),
      },
    );
  }
}
