import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const CustomButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    // Obtener el ancho de la pantalla
    double screenWidth = MediaQuery.of(context).size.width;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05), // 5% del ancho
          child: SizedBox(
            width: screenWidth * 0.8, // Botón con 80% del ancho de la pantalla
            height: 50, // Altura fija pero ajustable si es necesario
            child: ElevatedButton(
              onPressed: onPressed,
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith<Color>(
                  (Set<WidgetState> states) {
                    if (states.contains(WidgetState.pressed)) {
                      return const Color(0xFF434244); // Color al presionar (#434244)
                    }
                    return const Color(0xFFFF0000); // Color normal (#ff0000)
                  },
                ),
                foregroundColor: WidgetStateProperty.all<Color>(Colors.white), // Texto en blanco
                shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20), // Bordes redondeados
                  ),
                ),
                padding: WidgetStateProperty.all<EdgeInsets>(
                  const EdgeInsets.symmetric(vertical: 12), // Ajuste de padding vertical
                ),
              ),
              child: Text(
                text,
                style: TextStyle(
                  fontFamily: 'TitilliumWeb-SemiBold', // Fuente personalizada
                  fontSize: screenWidth * 0.045, // Tamaño de fuente proporcional
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
