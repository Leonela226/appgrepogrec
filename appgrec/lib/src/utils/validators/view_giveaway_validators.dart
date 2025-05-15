// lib/validations.dart
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:appgrec/src/widgets/custom_snackbar.dart';

// Validación de la fecha de inicio
String? validateStartDate(String? value, BuildContext context) {
  if (value == null || value.isEmpty) {
    CustomSnackbar.showError(context, 'Por favor, seleccione la fecha de inicio.');
    return ''; 
  }
  DateTime startDate = DateFormat('yyyy-MM-dd').parse(value);
  DateTime currentDate = DateTime.now();

  if (startDate.isBefore(DateTime(currentDate.year, currentDate.month, currentDate.day))) {
    CustomSnackbar.showWarning(context, 'La fecha de inicio no puede ser anterior al día de hoy.');
    return ''; 
  }
  return null; // Retornar null en vez de una cadena vacía
}

// Validación de la fecha de fin
String? validateEndDate(String? value, BuildContext context, TextEditingController startDateController) {
  if (value == null || value.isEmpty) {
    CustomSnackbar.showError(context, 'Por favor, seleccione la fecha de fin.');
    return ''; 
  }
  DateTime endDate = DateFormat('yyyy-MM-dd').parse(value);
  DateTime startDate = DateFormat('yyyy-MM-dd').parse(startDateController.text);
  if (endDate.isBefore(startDate)) {
    CustomSnackbar.showWarning(context, 'La fecha de fin debe ser igual o posterior a la fecha de inicio.');
    return ''; 
  }
  return null; 

// Validación de la fecha del sorteo
String? validateDrawDate(String? value, BuildContext context, TextEditingController endDateController) {
  if (value == null || value.isEmpty) {
    CustomSnackbar.showError(context, 'Por favor, seleccione la fecha del sorteo.');
    return ''; 
  }
  DateTime drawDate = DateFormat('yyyy-MM-dd').parse(value);
  DateTime endDate = DateFormat('yyyy-MM-dd').parse(endDateController.text);
  if (drawDate.isBefore(endDate)) {
    CustomSnackbar.showWarning(context, 'La fecha del sorteo debe ser igual o posterior a la fecha de fin.');
    return ''; 
  }
  return null; 
}


// Validación de campos vacíos
bool validateFields(
    BuildContext context,
    TextEditingController nameController,
    int? prizeCount,
    TextEditingController startDateController,
    TextEditingController endDateController,
    TextEditingController drawDateController) {
  if (nameController.text.isEmpty ||
      prizeCount == null ||
      startDateController.text.isEmpty ||
      endDateController.text.isEmpty ||
      drawDateController.text.isEmpty) {
    CustomSnackbar.showWarning(context, 'Todos los campos son requeridos.');
    return false;
  }


  return true;
}
