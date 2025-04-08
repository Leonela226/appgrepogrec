import 'package:flutter/material.dart';

class CustomDropdownButton<T> extends StatelessWidget {
  final String? labelText;
  final IconData? icon;  // Cambiar a tipo nullable para hacerlo opcional
  final List<T> items;
  final T? selectedValue;
  final Function(T?)? onChanged;
  final Color borderColor;
  final double borderRadius;
  final TextStyle? labelStyle;
  final TextStyle? itemTextStyle;
  final Widget? suffixIcon;

  const CustomDropdownButton({
    super.key,
    this.labelText,
    this.icon,
    required this.items,
    this.selectedValue,
    this.onChanged,
    this.borderColor = const Color(0xFFFF0000),
    this.borderRadius = 20.0,
    this.labelStyle,
    this.itemTextStyle,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05), // 5% del ancho de la pantalla
      child: SizedBox(
        width: screenWidth * 0.9, // Ancho del 90% de la pantalla
        child: DropdownButtonFormField<T>(
          value: selectedValue,
          onChanged: onChanged,
          decoration: InputDecoration(
            labelText: labelText,
            labelStyle: labelStyle ??
                TextStyle(
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
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide(color: borderColor),
            ),
            errorStyle: TextStyle(
              color: Colors.red,
              fontFamily: 'TitilliumWeb',
              fontWeight: FontWeight.w400, // Ligero
            ),
          ),
          style: itemTextStyle ??
              TextStyle(
                color: Colors.black,
                fontFamily: 'TitilliumWeb',
                fontWeight: FontWeight.normal,
                fontSize: screenWidth * 0.045,
              ),
          items: items
              .map((item) => DropdownMenuItem<T>(
                    value: item,
                    child: Text(item.toString()),
                  ))
              .toList(),
        ),
      ),
    );
  }
}
