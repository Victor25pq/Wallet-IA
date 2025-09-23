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

class MyApp extends StatelessWidget {
  // Cambiado de StatefulWidget a StatelessWidget
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WalletIA',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/', // La app siempre empieza en la SplashPage
      routes: {
        '/': (context) => const SplashPage(),
        '/login': (context) => const LoginPage(),
        '/home': (context) => const MainScreen(),
        // ... (el resto de tus rutas se mantienen igual)
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
