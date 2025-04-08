import 'dart:convert';
import 'dart:io'; // Necesario para trabajar con archivos
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart'; // Importa el paquete image_picker
import 'package:appgrec/src/widgets/custom_buttons_sec.dart';
import 'package:appgrec/src/widgets/custom_dropdownbottom.dart';
import 'package:appgrec/src/widgets/custom_snackbar.dart';
import 'package:appgrec/src/widgets/custom_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mime/mime.dart';

class GiveawayModal extends StatefulWidget {
  const GiveawayModal({super.key});

  @override
  GiveawayModalState createState() => GiveawayModalState();
}

class GiveawayModalState extends State<GiveawayModal> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _drawDateController = TextEditingController();
  int? _prizeCount; // Variable para almacenar la cantidad de premios seleccionados
  File? _imageFile;

  final ImagePicker _picker = ImagePicker();


  // Validación de campos vacíos
  bool _validateFields() {
    if (_nameController.text.isEmpty ||
        _prizeCount == null || // Verificar si se seleccionó una cantidad de premios
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

    // Comparar solo las fechas, sin importar la hora
    if (startDate.isBefore(DateTime(currentDate.year, currentDate.month, currentDate.day))) {
      CustomSnackbar.showWarning(context, 'La fecha de inicio no puede ser anterior al día de hoy.');
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
      CustomSnackbar.showWarning(context, 'La fecha de fin debe ser igual o posterior a la fecha de inicio.');
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
      CustomSnackbar.showWarning(context, 'La fecha del sorteo debe ser igual o posterior a la fecha de fin.');
      return ''; 
    }
    return null;
  }


  // Seleccionar imagen
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  // Crear el sorteo
  Future<void> _createGiveaway() async {
    if (!_validateFields()) {
      return;
    }

    // Verifica si no se ha seleccionado una imagen
    if (_imageFile == null) {
      CustomSnackbar.showWarning(context, 'Imagen no seleccionada');
      return;
    }

    final String? baseUrl = dotenv.env['FRONTEND_URL'];
    if (baseUrl == null || baseUrl.isEmpty) {
      if (mounted) {
        CustomSnackbar.showError(context, 'Error: FRONTEND_URL no está definida.');
      }
      return;
    }


    // Formatear las fechas para asegurarse de que solo se envíe la parte de la fecha (yyyy-MM-dd)
    String formattedStartDate = DateFormat('yyyy-MM-dd').format(DateTime.parse(_startDateController.text));
    String formattedEndDate = DateFormat('yyyy-MM-dd').format(DateTime.parse(_endDateController.text));
    String formattedDrawDate = DateFormat('yyyy-MM-dd').format(DateTime.parse(_drawDateController.text));

    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/api/giveaways/create'));

      request.fields['name'] = _nameController.text;
      request.fields['description'] = _descriptionController.text;
      request.fields['prize_count'] = _prizeCount.toString();
      request.fields['start_date'] = formattedStartDate;
      request.fields['end_date'] = formattedEndDate;
      request.fields['draw_date'] = formattedDrawDate;

    if (_imageFile != null) {
      final mimeType = lookupMimeType(_imageFile!.path);
      request.files.add(
        await http.MultipartFile.fromPath(
          'giveaway_image',
          _imageFile!.path,
          contentType: mimeType != null ? MediaType.parse(mimeType) : null,
        ),
      );
    }

     var response = await request.send();

    if (response.statusCode == 201) {
      final responseBody = await response.stream.bytesToString();
      final responseData = jsonDecode(responseBody);
      CustomSnackbar.showSuccess(context, responseData['message']);
      final newGiveaway = responseData['data'];
      Navigator.of(context).pop(newGiveaway);
    } else {
      final responseBody = await response.stream.bytesToString();
      final responseData = jsonDecode(responseBody);
      CustomSnackbar.showError(context, responseData['message']);
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

                GestureDetector(
                  onTap: _pickImage, // Selección de imagen
                  child: _imageFile == null
                  ? Container(
                    height: 100,
                    width: 100,
                    color: Colors.grey[300],
                    child: const Icon(Icons.camera_alt, size: 40),
                  )
                  : Image.file(_imageFile!, height: 100, width: 100, fit: BoxFit.cover),
                ),
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
                CustomDropdownButton<int>( // Dropdown para la cantidad de premios
                  labelText: 'Cantidad de premios',
                  icon: Icons.format_list_numbered,
                  selectedValue: _prizeCount,
                  onChanged: (int? newValue) {
                    setState(() {
                      _prizeCount = newValue;
                    });
                  },
                  items: List.generate(10, (index) => index + 1), // Lista de valores (1 a 10)
                ),
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
                    CustomBottonSec(text: 'Agregar', onPressed: _createGiveaway),
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
