import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const CustomButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20), // Márgenes a los lados
      child: ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith<Color>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.pressed)) {
                return Color(0xFF434244); // Color al presionar (#434244)
              }
              return Color(0xFFFF0000); // Color normal (#ff0000)
            },
          ),
          foregroundColor: WidgetStateProperty.all<Color>(Colors.white), // Texto en negro
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20), // Bordes redondeados
            ),
          ),
          padding: WidgetStateProperty.all<EdgeInsets>(
            EdgeInsets.symmetric(vertical: 14, horizontal: 18),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontFamily: 'TitilliumWeb-SemiBold', // Fuente personalizada
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
