import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({super.key, this.title = "App Grec"});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 4, // Sombra para destacar el AppBar
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/splash.png', // Ruta del logo de la empresa
            height: screenHeight * 0.06, // Tamaño del logo escalado (6% del alto de la pantalla)
          ),
          SizedBox(width: screenWidth * 0.02), // Espaciado dinámico
          Text(
            title,
            style: TextStyle(
              fontFamily: 'TitilliumWeb-Bold',
              fontSize: screenWidth * 0.05, // Tamaño de texto adaptativo
              color: Colors.black,
            ),
          ),
        ],
      ),
      centerTitle: true,
      iconTheme: const IconThemeData(color: Colors.black), // Íconos en negro
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
