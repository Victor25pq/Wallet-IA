// lib/main.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:login_app/models/finance_models.dart';
import 'package:login_app/screens/main_screen.dart';
import 'package:login_app/screens/splash_page.dart'; // Mantendremos tu splash page
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
      // La ruta inicial ahora será la SplashPage, que nos redirigirá
      initialRoute: '/',
      routes: {
        // La SplashPage ahora decide a dónde ir basado en el estado de autenticación
        '/': (context) => const AuthRedirect(),
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

// Este nuevo Widget escuchará los cambios de autenticación
class AuthRedirect extends StatefulWidget {
  const AuthRedirect({super.key});

  @override
  State<AuthRedirect> createState() => _AuthRedirectState();
}

class _AuthRedirectState extends State<AuthRedirect> {
  StreamSubscription<AuthState>? _authStateSubscription;

  @override
  void initState() {
    super.initState();
    // Inmediatamente después de que el primer frame es dibujado,
    // revisamos la sesión y configuramos el oyente.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Si ya hay una sesión cuando la app arranca, vamos a /home
      final currentSession = supabase.auth.currentSession;
      if (currentSession != null) {
        Navigator.of(context).pushReplacementNamed('/home');
        return;
      }

      // Si no, nos quedamos en la Splash y escuchamos el siguiente cambio.
      // Este oyente capturará el evento después del login de Google.
      _authStateSubscription = supabase.auth.onAuthStateChange.listen((data) {
        final session = data.session;
        if (session != null) {
          Navigator.of(context).pushReplacementNamed('/home');
        } else {
          // Si el evento no tiene sesión (ej. logout), vamos a /login
          Navigator.of(context).pushReplacementNamed('/login');
        }
      });
    });
  }

  @override
  void dispose() {
    // Es muy importante cancelar la suscripción para evitar errores.
    _authStateSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Muestra la pantalla de carga mientras se determina el estado de la sesión
    return const SplashPage();
  }
}
