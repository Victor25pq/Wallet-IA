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
      final redirectTo = kIsWeb
          ? null
          : 'io.supabase.flutterquickstart://login-callback/';

      // --- NUEVO: AÑADIR ESTE PRINT ---
      print('Iniciando signInWithOAuth con redirectTo: $redirectTo');

      await supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: redirectTo,
      );
    } catch (error, stackTrace) {
      if (mounted) {
        // --- NUEVO: AÑADIR ESTOS PRINTS ---
        print('!!!!!!!!!! ERROR EN signInWithOAuth !!!!!!!!!!');
        print('Error: $error');
        print('StackTrace: $stackTrace');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al iniciar sesión: $error')),
        );
      }
    } finally {
      // No cambiaremos el finally por ahora, aunque no es ideal,
      // queremos ver si el 'catch' nos da alguna pista.
      if (mounted) {
        // setState(() => _isLoading = false); // Comentado temporalmente
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
