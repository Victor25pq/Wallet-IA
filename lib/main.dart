// lib/main.dart

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:login_app/screens/main_screen.dart';
import 'package:login_app/screens/splash_page.dart'; // Importamos la nueva página
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
  @override
  void initState() {
    super.initState();
    // Escuchamos los cambios de estado de autenticación
    supabase.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      if (event == AuthChangeEvent.signedIn) {
        // Cuando el usuario inicia sesión, lo llevamos a '/home'
        // Esto se disparará después de que el login con Google sea exitoso
        Navigator.of(context).pushReplacementNamed('/home');
      } else if (event == AuthChangeEvent.signedOut) {
        Navigator.of(context).pushReplacementNamed('/login');
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

      // La ruta inicial ahora es la splash page
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashPage(),
        '/login': (context) => const LoginPage(),
        '/home': (context) => const MainScreen(),
        // Mantenemos tus otras rutas
        '/add_transaction': (context) {
          final type =
              ModalRoute.of(context)!.settings.arguments as TransactionType;
          return AddTransactionPage(type: type);
        },
        '/transfer': (context) => const TransferPage(),
        '/all_transactions': (context) => const AllTransactionsPage(),
      },
    );
  }
}
