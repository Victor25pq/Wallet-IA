// En screens/login_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginPage extends StatelessWidget {
  // Como la pantalla ya no gestiona ningún estado (colores, foco),
  // la podemos convertir en un StatelessWidget, que es más simple.
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Para facilitar la lectura, separamos el color primario en una variable
    final Color primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      body: Container(
        // 1. EL FONDO CON GRADIENTE
        // Usamos un Container para decorar el fondo de toda la pantalla.
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE3F2FD), // Un azul muy claro
              Color(0xFFFFFFFF), // Blanco
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 2. LA ILUSTRACIÓN SUPERIOR
                // Expanded permite que la imagen ocupe el espacio disponible
                Expanded(
                  flex: 3, // Le damos más peso para que ocupe más espacio
                  child: SvgPicture.asset(
                    'assets/wallet_illustration.svg', // Necesitarás añadir esta imagen
                  ),
                ),

                // 3. EL TEXTO PRINCIPAL
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

                // 5. EL BOTÓN DE ACCIÓN
                ElevatedButton(
                  onPressed: () {
                    // Aquí irá la lógica para iniciar sesión con Google
                    Navigator.pushNamed(context, '/home');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor, // Usamos el color del tema
                    foregroundColor: Colors.white, // Color del texto e ícono
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50), // Muy redondeado
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/google_logo.png', height: 24.0),
                      SizedBox(width: 8),
                      Text(
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
