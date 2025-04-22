import 'package:flutter/material.dart';

class CustomDropdownButton<T> extends StatelessWidget {
  final String? labelText;
  final IconData? icon; // Icono opcional
  final List<T> items;
  final T? selectedValue;
  final Function(T?)? onChanged;
  final Color borderColor;
  final double borderRadius;
  final TextStyle? labelStyle;
  final TextStyle? itemTextStyle;
  final Widget? suffixIcon;
  final double? width;
  final double? height;


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
    this.width,
    this.height,

  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
      child: SizedBox(
        width: width ?? screenWidth * 0.9,
        child: DropdownButtonFormField<T>(
          value: selectedValue,
          onChanged: onChanged,
          decoration: InputDecoration(
            labelText: labelText,
            labelStyle: labelStyle ??
                TextStyle(
                  color: Colors.black,
                  fontFamily: 'TitilliumWeb',
                  fontWeight: FontWeight.w600,
                  fontSize: screenWidth * 0.04,
                ),
            prefixIcon: icon != null
                ? Icon(
                    icon,
                    color: Colors.black,
                    size: screenWidth * 0.05,
                  )
                : null,
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
              fontWeight: FontWeight.w400,
            ),
          ),
          style: itemTextStyle ??
              TextStyle(
                color: Colors.black,
                fontFamily: 'TitilliumWeb',
                fontWeight: FontWeight.normal,
                fontSize: screenWidth * 0.035,
              ),
          items: items
              .map((item) {
                String displayText = '';
                if (item is Map<String, dynamic>) {
                  displayText = item['name_prize'] ?? 'Sin nombre';
                } else {
                  displayText = item.toString();
                }
                return DropdownMenuItem<T>(
                  value: item,
                  child: Text(displayText),
                );
              })
              .toList(),
        ),
      ),
    );
  }
}
