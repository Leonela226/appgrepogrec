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
  final Function(String)? onChanged; // Parámetro opcional
  final int? minLines; // Agregado
  final int? maxLines; // Agregado 

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
    this.onChanged, // No es obligatorio
    this.minLines = 1, // Valor predeterminado
    this.maxLines = 1, // Valor predeterminado
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
          onChanged: onChanged, // Se usará solo si se pasa
          keyboardType: keyboardType,
          obscureText: obscureText,
          decoration: InputDecoration(
            labelText: labelText,
            labelStyle: TextStyle(
              color: Colors.black,
              fontFamily: 'TitilliumWeb',
              fontWeight: FontWeight.w600, // SemiBold
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
            errorStyle: TextStyle(
              color: Colors.red, // Puedes cambiar el color si lo deseas
              fontFamily: 'TitilliumWeb', // Aplica la fuente personalizada para errores
              fontWeight: FontWeight.w400, // Usando la variante Light
            ),
          ),
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'TitilliumWeb',
            fontWeight: FontWeight.normal, // Regular
            fontSize: screenWidth * 0.045, // Fuente adaptativa
          ),
          cursorColor: Color(0xFF434244), // Aquí es donde cambias el color del cursor
          validator: validator,
          maxLength: maxLength,
          focusNode: focusNode, // Asignar el FocusNode
          onFieldSubmitted: onFieldSubmitted, // Asignar la función de submit
          maxLengthEnforcement: maxLength == null ? null : MaxLengthEnforcement.enforced, // Evita el contador visible para el campo de teléfono
          minLines: minLines, // Usamos el minLines
          maxLines: maxLines, // Usamos el maxLines
        ),
      ),
    );
  }
}
