import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:appgrec/src/widgets/custom_snackbar.dart';
import 'package:appgrec/src/widgets/custom_text_form_field.dart';
import 'package:appgrec/src/widgets/custom_buttons_sec.dart';
import 'package:mime/mime.dart';  // Importamos el paquete mime
import 'dart:convert'; // Asegúrate de importar 'dart:convert' para decodificar la respuesta JSON.

class PrizeFormBottomSheet extends StatefulWidget {
  final Function(String, String, File?)? onSave;

  const PrizeFormBottomSheet({super.key, this.onSave});

  @override
  PrizeFormBottomSheetState createState() => PrizeFormBottomSheetState();
}

class PrizeFormBottomSheetState extends State<PrizeFormBottomSheet> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  // Seleccionar imagen
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  // Función para subir el premio
// Función para subir el premio
Future<void> _uploadPrize() async {
  if (_nameController.text.isEmpty || _descriptionController.text.isEmpty) {
    CustomSnackbar.showWarning(context, 'Todos los campos son requeridos.');
    return;
  }

  // Verifica si ya se han ingresado nombre y descripción, pero no se ha seleccionado una imagen
  if (_nameController.text.isNotEmpty && _descriptionController.text.isNotEmpty && _imageFile == null) {
    CustomSnackbar.showWarning(context, 'Imagen no seleccionada');
    return;
  }

  final String? backendUrl = dotenv.env['FRONTEND_URL'];
  if (backendUrl == null || backendUrl.isEmpty) {
    CustomSnackbar.showError(context, 'Error: FRONTEND_URL no está definida.');
    return;
  }

  var request = http.MultipartRequest('POST', Uri.parse('$backendUrl/api/prizes/create'));

  request.fields['name_prize'] = _nameController.text;
  request.fields['description_prize'] = _descriptionController.text;

  if (_imageFile != null) {
    print("Archivo a enviar: ${_imageFile!.path}");

    // Usamos 'mime' para obtener el tipo MIME correcto
    final mimeType = lookupMimeType(_imageFile!.path);
    request.files.add(
      await http.MultipartFile.fromPath(
        'prize_image',
        _imageFile!.path,
        contentType: mimeType != null ? MediaType.parse(mimeType) : null,
      ),
    );
  } else {
    print("No se ha seleccionado ninguna imagen.");
  }

  try {
    var response = await request.send();

    // Obtener el cuerpo de la respuesta
    var responseBody = await response.stream.bytesToString();
    if (response.statusCode == 201) {
      var jsonResponse = json.decode(responseBody);
      String newImageUrl = jsonResponse['data']['image_url'];

      // Aquí puedes usar la URL de la imagen como necesites
      print("URL de la imagen: $newImageUrl");

      // Llamar a la función onSave con la nueva URL de la imagen
      widget.onSave?.call(_nameController.text, _descriptionController.text, _imageFile);  // Llamar la función onSave

      CustomSnackbar.showSuccess(context, 'Premio agregado correctamente.');
      Navigator.of(context).pop(); // Cerrar modal después de éxito
    } else {
      CustomSnackbar.showError(context, 'Error al subir el premio: ${response.statusCode}');
    }
  } catch (e) {
    CustomSnackbar.showError(context, 'Error en la subida: $e');
  }
}


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();  // Cerrar el teclado al tocar fuera del formulario
      },
      child: Scaffold(
        body: SingleChildScrollView(  // Permite que el contenido se desplace si el teclado aparece
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Agregar Premio",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
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
                CustomTextFormField(
                  labelText: 'Nombre del Premio',
                  controller: _nameController,
                  icon: Icons.card_giftcard,
                ),
                const SizedBox(height: 10),
                // Aquí ajustamos el CustomTextFormField para la descripción
                CustomTextFormField(
                  labelText: 'Descripción del Premio',
                  controller: _descriptionController,
                  icon: Icons.description,
                  maxLines: null,  // Permite que el campo de descripción se expanda según sea necesario
                  keyboardType: TextInputType.multiline, // Asegura que se habiliten saltos de línea
                  minLines: 3, // Comienza con al menos 3 líneas visibles
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CustomBottonSec(
                      text: 'Cancelar',
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    CustomBottonSec(
                      text: 'Agregar',
                      onPressed: _uploadPrize,
                    ),
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
