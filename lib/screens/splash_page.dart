import 'package:flutter/material.dart';
import 'package:login_app/main.dart'; // Para acceder a supabase

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _redirect();
  }

  Future<void> _redirect() async {
    // Esperamos un momento para que la UI se construya
    await Future.delayed(Duration.zero);

    if (!mounted) {
      return;
    }

    final session = supabase.auth.currentSession;
    if (session != null) {
      // Si hay sesión, vamos a home
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      // Si no, vamos a login
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
