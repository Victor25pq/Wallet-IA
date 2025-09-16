// lib/screens/login_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:login_app/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      // ESTA ES LA ÚNICA LLAMADA QUE NECESITAS
      await supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        // Supabase maneja los redirects automáticamente en web.
        // En un futuro, aquí configuraríamos el deep link para Android/iOS.
        redirectTo: kIsWeb
            ? null
            : 'io.supabase.flutterquickstart://login-callback/',
      );

      // ¡Y ya está! Supabase gestiona todo.
      // No necesitamos navegar manualmente, Supabase lo hará por nosotros
      // al detectar el cambio de sesión, pero por ahora lo dejamos así.
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al iniciar sesión: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE3F2FD), Color(0xFFFFFFFF)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 3,
                  child: SvgPicture.asset('assets/wallet_illustration.svg'),
                ),
                const Text(
                  'Gestión financiera sin esfuerzo al alcance de tu mano',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _isLoading ? null : _signInWithGoogle,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset('assets/google_logo.png', height: 24.0),
                            const SizedBox(width: 8),
                            const Text(
                              'Iniciar sesión',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
