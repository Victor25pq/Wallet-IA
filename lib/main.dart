// Importamos el paquete principal de Flutter para usar los widgets de Material Design.
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:login_app/screens/main_screen.dart';
import 'package:login_app/screens/transfer_page.dart';
import 'screens/login_page.dart';
import 'screens/add_transaction_page.dart';
import 'screens/all_transactions_page.dart';

// El punto de entrada de toda aplicación en Flutter.
Future<void> main() async {
  // 3. INICIALIZA FLUTTER Y EL FORMATO DE FECHA
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_ES', null);

  runApp(const MyApp());
}

// El widget principal de nuestra aplicación.
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

      // LA NAVEGACIÓN SE GESTIONA AQUÍ
      home: const LoginPage(),
      onGenerateRoute: (settings) {
        // 'settings' contiene el nombre y los argumentos de la ruta que se está pidiendo
        switch (settings.name) {
          case '/home':
            return MaterialPageRoute(builder: (context) => const MainScreen());

          case '/add_transaction':
            // Este es el 'case' que el error no está encontrando.
            // Nos aseguramos de que exista y esté escrito correctamente.
            final type = settings.arguments as TransactionType;
            return MaterialPageRoute(
              builder: (context) => AddTransactionPage(type: type),
            );
          case '/transfer':
            return MaterialPageRoute(
              builder: (context) => const TransferPage(),
            );
          case '/all_transactions':
            return MaterialPageRoute(
              builder: (context) => const AllTransactionsPage(),
            );

          default:
            // Una ruta por defecto por si algo falla.
            return MaterialPageRoute(builder: (context) => const LoginPage());
        }
      },
    );
  }
}
