import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({super.key, this.title = "App Grec"});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 4, // Sombra para destacar el appbar
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/splash.png', // Ruta del logo de la empresa
            height: 40, // Ajusta el tamaño del logo
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'TitilliumWeb-Bold',
              fontSize: 20,
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
