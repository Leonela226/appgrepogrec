import 'package:flutter/material.dart';

class CustomBottonSec extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color backgroundColor; 
  final Color textColor;
  final double borderRadius;
  final double paddingVertical;
  final double paddingHorizontal;

  const CustomBottonSec({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor = const Color(0xFFFF0000), // Color rojo predeterminado
    this.textColor = Colors.white, // Color del texto predeterminado
    this.borderRadius = 20.0, // Radio de borde adecuado para un botón ovalado (más pequeño)
    this.paddingVertical = 8.0, // Padding vertical reducido
    this.paddingHorizontal = 16.0, // Padding horizontal reducido
  });

  @override
  Widget build(BuildContext context) {
    // Obtener el ancho de la pantalla
    double screenWidth = MediaQuery.of(context).size.width;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04), // 5% del ancho
          child: SizedBox(
            width: screenWidth * 0.3, // Botón con 30% del ancho de la pantalla
            height: 40, // Altura más pequeña
            child: ElevatedButton(
              onPressed: onPressed,
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith<Color>(
                  (Set<WidgetState> states) {
                    if (states.contains(WidgetState.pressed)) {
                      return const Color(0xFF434244); // Color al presionar (#434244)
                    }
                    return backgroundColor; // Color normal
                  },
                ),
                foregroundColor: WidgetStateProperty.all<Color>(textColor), // Texto en blanco
                shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(borderRadius), // Bordes redondeados
                  ),
                ),
                padding: WidgetStateProperty.all<EdgeInsets>(
                  const EdgeInsets.symmetric(vertical: 8.0), // Ajuste de padding vertical
                ),
              ),
              child: Text(
                text,
                style: TextStyle(
                  fontFamily: 'TitilliumWeb', // Fuente personalizada 
                  fontWeight: FontWeight.w600, // Peso SemiBold
                  fontSize: screenWidth * 0.04, // Tamaño de fuente más pequeño y proporcional
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
