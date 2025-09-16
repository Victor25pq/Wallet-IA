// En screens/main_screen.dart

import 'package:flutter/material.dart';
import 'home_page.dart'; // Asegúrate que la ruta sea correcta
import 'all_transactions_page.dart';
import 'settings_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // 1. Guardamos el índice de la pestaña seleccionada
  int _selectedIndex = 0;

  // 2. Creamos una lista con las pantallas que mostraremos
  // Por ahora, las otras son solo placeholders
  static const List<Widget> _widgetOptions = <Widget>[
    HomePage(), // Nuestra HomePage real
    AllTransactionsPage(),
    Text('Página de Chat'),
    SettingsPage(),
  ];

  // 3. Esta función se llama cuando se toca una pestaña
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 4. Este es el Scaffold principal que contiene la barra de navegación
    return Scaffold(
      // 5. El body cambia dinámicamente según la pestaña seleccionada
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Stats'),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped, // Conectamos la función
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: false,
        showSelectedLabels: false,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
