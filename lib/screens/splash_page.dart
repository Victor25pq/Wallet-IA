// lib/screens/splash_page.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:login_app/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  StreamSubscription<AuthState>? _authStateSubscription;

  @override
  void initState() {
    super.initState();
    _redirect();
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }

  void _redirect() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      // 1. Verificamos si ya existe una sesión para una redirección rápida.
      final session = supabase.auth.currentSession;
      if (session != null) {
        Navigator.of(context).pushReplacementNamed('/home');
        return; // Salimos de la función si ya redirigimos.
      }

      // 2. Si no hay sesión, escuchamos el primer evento del stream.
      //    Esto manejará tanto el caso de "no hay sesión" como el caso
      //    de que la sesión llegue a través del deep link.
      _authStateSubscription = supabase.auth.onAuthStateChange.listen((data) {
        // Nos aseguramos de cancelar la suscripción para evitar múltiples redirecciones.
        _authStateSubscription?.cancel();

        if (data.session != null) {
          Navigator.of(context).pushReplacementNamed('/home');
        } else {
          Navigator.of(context).pushReplacementNamed('/login');
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
