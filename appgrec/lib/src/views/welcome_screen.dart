import 'dart:ui';
import 'package:appgrec/src/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:appgrec/src/widgets/custom_buttons_prim.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Imagen de fondo con desenfoque
          Positioned.fill(
            child: Image.asset(
              'assets/images/patron1.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1.5),
              child: Container(
                color: const Color.fromARGB(5, 0, 0, 0),
              ),
            ),
          ),

          // Contenido centrado
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 500, // Máximo ancho para que no se vea exageradamente extendido en pantallas grandes
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.08,
                      vertical: size.height * 0.02,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min, // Evita que ocupe todo el alto disponible
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Logo
                        Image.asset(
                          'assets/images/splash.png',
                          width: size.width * 0.4,
                        ),
                        SizedBox(height: size.height * 0.05),

                        // Título
                        Text(
                          'Bienvenido a tu App Grec',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: size.width * 0.07,
                            fontFamily: 'TitilliumWeb',
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                            shadows: [
                              Shadow(
                                color: Color.fromARGB(88, 0, 0, 0),
                                offset: Offset(1, 1),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: size.height * 0.02),

                        // Descripción
                        Text(
                          'Escanea tus facturas y participa en sorteos.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: size.width * 0.045,
                            fontFamily: 'TitilliumWeb',
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                            shadows: [
                              Shadow(
                                color: Color.fromARGB(55, 0, 0, 0),
                                offset: Offset(1, 1),
                                blurRadius: 3,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: size.height * 0.06),

                        // Botones
                        CustomButton(
                          text: 'Iniciar sesión',
                          onPressed: () {
                            Navigator.pushNamed(context, Routes.login);
                          },
                        ),
                        SizedBox(height: size.height * 0.03),
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}
