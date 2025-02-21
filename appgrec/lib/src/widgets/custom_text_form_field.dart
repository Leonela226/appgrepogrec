import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextFormField extends StatelessWidget {
  final String labelText;
  final IconData icon;
  final TextInputType keyboardType;
  final bool obscureText;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final int? maxLength; // Agregado para limitar la longitud de caracteres
  final FocusNode? focusNode; // Para manejar el enfoque
  final ValueChanged<String>? onFieldSubmitted; // Agregado para manejar la acción al enviar el campo
  final Widget? suffixIcon; // Agregar parámetro para el ícono adicional

  const CustomTextFormField({
    super.key,
    required this.labelText,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    required this.controller,
    this.validator,
    this.maxLength, // Aceptar el límite de longitud
    this.focusNode, // Para manejar el enfoque
    this.onFieldSubmitted, // Aceptar el parámetro para la acción de enviar
    this.suffixIcon, // Recibir el parámetro de ícono adicional
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05), // 5% del ancho de la pantalla
      child: SizedBox(
        width: screenWidth * 0.9, // Campo con 90% del ancho de la pantalla
        child: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          decoration: InputDecoration(
            labelText: labelText,
            labelStyle: TextStyle(
              color: Colors.black,
              fontFamily: 'TitilliumWeb-SemiBold',
              fontSize: screenWidth * 0.04, // Fuente adaptativa
            ),
            prefixIcon: Icon(
              icon,
              color: Colors.black,
              size: screenWidth * 0.06, // Tamaño del ícono adaptativo
            ),
            suffixIcon: suffixIcon, // Aquí agregamos el 'suffixIcon'
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Color(0xFFFF0000)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Color(0xFFFF0000)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Color(0xFFFF0000)),
            ),
            counterText: '', // Esto eliminará el texto del contador
          ),
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'TitilliumWeb-Regular',
            fontSize: screenWidth * 0.045, // Fuente adaptativa
          ),
          validator: validator,
          maxLength: maxLength,
          focusNode: focusNode, // Asignar el FocusNode
          onFieldSubmitted: onFieldSubmitted, // Asignar la función de submit
          maxLengthEnforcement: maxLength == null ? null : MaxLengthEnforcement.enforced, // Evita el contador visible para el campo de teléfono
        ),
      ),
    );
  }
}
