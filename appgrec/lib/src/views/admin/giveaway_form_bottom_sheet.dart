import 'dart:convert';
import 'package:appgrec/src/widgets/custom_buttons_sec.dart';
import 'package:appgrec/src/widgets/custom_snackbar.dart';
import 'package:appgrec/src/widgets/custom_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GiveawayModal extends StatefulWidget {
  const GiveawayModal({super.key});

  @override
  GiveawayModalState createState() => GiveawayModalState();
}

class GiveawayModalState extends State<GiveawayModal> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _prizeCountController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _drawDateController = TextEditingController();

  // Validación de campos vacíos
  bool _validateFields() {
    if (_nameController.text.isEmpty ||
        _prizeCountController.text.isEmpty ||
        _startDateController.text.isEmpty ||
        _endDateController.text.isEmpty ||
        _drawDateController.text.isEmpty) {
      CustomSnackbar.showWarning(context, 'Todos los campos son requeridos.');
      return false;
    }

    // Validaciones de fechas
    if (validateStartDate(_startDateController.text) != null ||
        validateEndDate(_endDateController.text) != null ||
        validateDrawDate(_drawDateController.text) != null) {
      return false;
    }

    return true;
  }

  // Selector de fechas
  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  // Validación de la fecha de inicio
  String? validateStartDate(String? value) {
    if (value == null || value.isEmpty) {
      CustomSnackbar.showError(context, 'Por favor, seleccione la fecha de inicio.');
      return ''; 
    }
    DateTime startDate = DateFormat('yyyy-MM-dd').parse(value);
    DateTime currentDate = DateTime.now();
    if (startDate.isBefore(currentDate)) {
      CustomSnackbar.showError(context, 'La fecha de inicio no puede ser anterior a hoy.');
      return ''; 
    }
    return null;
  }

  // Validación de la fecha de fin
  String? validateEndDate(String? value) {
    if (value == null || value.isEmpty) {
      CustomSnackbar.showError(context, 'Por favor, seleccione la fecha de fin.');
      return ''; 
    }
    DateTime endDate = DateFormat('yyyy-MM-dd').parse(value);
    DateTime startDate = DateFormat('yyyy-MM-dd').parse(_startDateController.text);
    if (endDate.isBefore(startDate)) {
      CustomSnackbar.showError(context, 'La fecha de fin debe ser igual o posterior a la fecha de inicio.');
      return ''; 
    }
    return null;
  }

  // Validación de la fecha del sorteo
  String? validateDrawDate(String? value) {
    if (value == null || value.isEmpty) {
      CustomSnackbar.showError(context, 'Por favor, seleccione la fecha del sorteo.');
      return ''; 
    }
    DateTime drawDate = DateFormat('yyyy-MM-dd').parse(value);
    DateTime endDate = DateFormat('yyyy-MM-dd').parse(_endDateController.text);
    if (drawDate.isBefore(endDate)) {
      CustomSnackbar.showError(context, 'La fecha del sorteo debe ser igual o posterior a la fecha de fin.');
      return ''; 
    }
    return null;
  }

  // Crear el sorteo
  Future<void> _createGiveaway() async {
    if (!_validateFields()) {
      return;
    }

    final String? backendUrl = dotenv.env['FRONTEND_URL'];
    if (backendUrl == null || backendUrl.isEmpty) {
      CustomSnackbar.showError(context, 'Error: FRONTEND_URL no está definida.');
      return;
    }

    final String apiUrl = '$backendUrl/api/giveaways/create';

    // Formatear las fechas para asegurarse de que solo se envíe la parte de la fecha (yyyy-MM-dd)
    String formattedStartDate = DateFormat('yyyy-MM-dd').format(DateTime.parse(_startDateController.text));
    String formattedEndDate = DateFormat('yyyy-MM-dd').format(DateTime.parse(_endDateController.text));
    String formattedDrawDate = DateFormat('yyyy-MM-dd').format(DateTime.parse(_drawDateController.text));

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': _nameController.text,
        'description': _descriptionController.text,
        'prize_count': int.tryParse(_prizeCountController.text) ?? 0,
        'start_date': formattedStartDate,
        'end_date': formattedEndDate,
        'draw_date': formattedDrawDate,
      }),
    );

    if (response.statusCode == 201) {
      final responseBody = jsonDecode(response.body);
      final newGiveaway = responseBody['data'];

      CustomSnackbar.showSuccess(context, responseBody['message']);
      Navigator.of(context).pop(newGiveaway);
    } else {
      final responseBody = jsonDecode(response.body);
      CustomSnackbar.showError(context, responseBody['message']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text("Crear Sorteo", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                CustomTextFormField(labelText: 'Nombre del sorteo', controller: _nameController, icon: Icons.card_giftcard),
                const SizedBox(height: 10),
                CustomTextFormField(
                  labelText: 'Descripción',
                  controller: _descriptionController,
                  icon: Icons.description,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  minLines: 3,
                ),
                const SizedBox(height: 10),
                CustomTextFormField(labelText: 'Cantidad de premios', controller: _prizeCountController, icon: Icons.format_list_numbered, keyboardType: TextInputType.number),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => _selectDate(context, _startDateController),
                  child: AbsorbPointer(
                    child: CustomTextFormField(
                      labelText: 'Fecha de inicio',
                      icon: Icons.calendar_today,
                      controller: _startDateController,
                      validator: validateStartDate,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => _selectDate(context, _endDateController),
                  child: AbsorbPointer(
                    child: CustomTextFormField(
                      labelText: 'Fecha de fin',
                      icon: Icons.calendar_today,
                      controller: _endDateController,
                      validator: validateEndDate,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => _selectDate(context, _drawDateController),
                  child: AbsorbPointer(
                    child: CustomTextFormField(
                      labelText: 'Fecha del sorteo',
                      icon: Icons.calendar_today,
                      controller: _drawDateController,
                      validator: validateDrawDate,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomBottonSec(text: 'Cancelar', onPressed: () => Navigator.of(context).pop()),
                    CustomBottonSec(text: 'Guardar', onPressed: _createGiveaway),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
