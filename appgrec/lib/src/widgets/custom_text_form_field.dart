import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  final String labelText;
  final IconData icon;
  final TextInputType keyboardType;
  final bool obscureText;
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const CustomTextFormField({super.key, 
    required this.labelText,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    required this.controller,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(
          color: Colors.black, 
          fontFamily: 'TitilliumWeb-SemiBold', 
        ),
        prefixIcon: Icon(icon, color: Colors.black),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20), 
          borderSide: BorderSide(color: Color(0xFFFF0000)), 
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Color(0xFFFF0000)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Color(0xFFFF0000)),
        ),
      ),
      style: TextStyle(
        color: Colors.black, 
        fontFamily: 'TitilliumWeb-Regular', 
      ),
      validator: validator,
    );
  }
}
