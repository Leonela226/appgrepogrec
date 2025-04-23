import 'dart:convert';
import 'dart:io'; // Necesario para trabajar con archivos
import 'package:appgrec/src/utils/validators/view_giveaway_validators.dart';
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
  
  int? _prizeCount;
  File? _imageFile;

  // Lista de sucursales obtenida del backend
  List<Map<String, dynamic>> _branches = [];
  
  // Lista para almacenar las sucursales seleccionadas
  final List<int> _selectedBranches = [];


  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchBranches(); // Cargar las sucursales cuando el modal se crea
  }

  // Función para obtener las sucursales desde el backend
  Future<void> _fetchBranches() async {
    final String? baseUrl = dotenv.env['FRONTEND_URL'];
    final response = await http.get(Uri.parse('$baseUrl/api/branch/all'));

    if (response.statusCode == 200) {

      final Map<String, dynamic> responseData = json.decode(response.body); // Asegúrate de que responseData esté definida correctamente

    // Accede a la clave 'data' que contiene la lista de sucursales
    final List<dynamic> branchList = responseData['data'];  // Renombramos la variable a branchList
    
      //print('Branch Data: $branchList');

      setState(() {
        _branches = List<Map<String, dynamic>>.from(branchList); // Asigna la lista de sucursales a _branches
      });
    } else {
      CustomSnackbar.showError(context, 'Error al obtener las sucursales.');
    }
  }

  // Función para manejar el cambio en el estado de los checkboxes
  void _onBranchSelected(bool? selected, int branchId) {
    setState(() {
      if (selected == true) {
        _selectedBranches.add(branchId);
      } else {
        _selectedBranches.remove(branchId);
      }
    });
  }

  // Validación de campos vacíos
  bool _validateFields() {
    return validateFields(
      context,
      _nameController,
      _prizeCount,
      _startDateController,
      _endDateController,
      _drawDateController,
    );
  }

  bool _validateDates() {
    if (validateStartDate(_startDateController.text, context) != null ||
        validateEndDate(_endDateController.text, context, _startDateController) != null ||
        validateDrawDate(_drawDateController.text, context, _endDateController) != null) {
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
    if (!_validateFields() || !_validateDates()) {
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
    request.fields['selected_branches'] = jsonEncode(_selectedBranches); // Agregar sucursales seleccionadas

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
                Text("Crear Sorteo", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'TitilliumWeb')),
                const SizedBox(height: 10),

                GestureDetector(
                  onTap: _pickImage,
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
                CustomDropdownButton<int>( 
                  labelText: 'Cantidad de premios',
                  icon: Icons.format_list_numbered,
                  selectedValue: _prizeCount,
                  onChanged: (int? newValue) {
                    setState(() {
                      _prizeCount = newValue;
                    });
                  },
                  items: List.generate(10, (index) => index + 1),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => _selectDate(context, _startDateController),
                  child: AbsorbPointer(
                    child: CustomTextFormField(
                      labelText: 'Fecha de inicio',
                      icon: Icons.calendar_today,
                      controller: _startDateController,
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
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Sección de sucursales con checkboxes
                if (_branches.isNotEmpty) ...[
                  Text("Selesccione la disponibilidad del sorteo", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'TitilliumWeb')),
                  const SizedBox(height: 5),
                  Column(
                    children: _branches.map((branch) {
                     final String branchName = branch['name_branch'] ?? 'Sin nombre'; // Valida si el nombre es nulo
                      final int branchId = branch['id_branch'] ?? -1; // Valida si el id es null

                      return CheckboxListTile(
                        title: Text(branchName,
                        style: TextStyle(
                           fontFamily: 'TitilliumWeb',  // Tipo de fuente
                           fontSize: 14,  // Tamaño de la fuente
                           fontWeight: FontWeight.w600,  // Peso de la fuente
                           color: Colors.black,  // Color de la fuente
                        ),
                      ),
                        value: _selectedBranches.contains(branchId),
                        onChanged: (bool? selected) {
                          _onBranchSelected(selected, branchId);
                        },
                        visualDensity: VisualDensity(vertical: -3), // Reduce el espacio vertical
                        // Cambiar color de selección
                        activeColor: Colors.green,        // Color del check y fondo cuando está seleccionado
                        checkColor: Colors.white,         // Color del ícono del check                                    
                      );
                    }).toList(),
                  ),
                ],
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
