import 'dart:ui';
import 'package:appgrec/src/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:appgrec/src/widgets/custom_buttons_prim.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Imagen de fondo con desenfoque
          Positioned.fill(
            child: Image.asset(
              'assets/images/patron1.png', // Ruta de la imagen del patrón
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1.5), // Desenfoque
              child: Container(
                color: const Color.fromARGB(5, 0, 0, 0), // Reemplazo de withOpacity(0.2)
              ),
            ),
          ),

          // Contenido encima del fondo
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo de la empresa
                  Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Image.asset(
                      'assets/images/splash.png', // Ruta del logo
                      width: 150, // Ajusta el tamaño del logo
                    ),
                  ),

                  // Título de la aplicación
                  Text(
                    'Bienvenido a tu App Grec',
                    style: TextStyle(
                      fontSize: 30,
                      fontFamily: 'TitilliumWeb', // TitilliumWeb-SemiBold
                      fontWeight: FontWeight.w600, // SemiBold
                      color: Colors.black,
                      shadows: [
                        Shadow(
                          color: Color.fromARGB(88, 0, 0, 0), // 179 es aproximadamente 70% de opacidad (0.7 * 255)
                          offset: Offset(1, 1),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),

                  // Descripción corta de la app
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      'Escanea tus facturas y participa en sorteos.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'TitilliumWeb', // TitilliumWeb-Regular
                        fontWeight: FontWeight.w400, // Regular
                        color: Colors.black,
                        shadows: [
                          Shadow(
                            color: Color.fromARGB(55, 0, 0, 0), // 70% de opacidad
                            offset: Offset(1, 1),
                            blurRadius: 3,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 40),

                  // Botón para ir a iniciar sesión
                  CustomButton(
                    text: 'Iniciar sesión',
                    onPressed: () {
                      Navigator.pushNamed(context, Routes.login);
                    },
                  ),
                  SizedBox(height: 20),

                  // Botón para ir a registrarse
                  CustomButton(
                    text: 'Registrarse',
                    onPressed: () {
                      Navigator.pushNamed(context, Routes.register);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
