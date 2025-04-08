import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:appgrec/src/widgets/custom_snackbar.dart';
import 'package:appgrec/src/widgets/custom_text_form_field.dart';
import 'package:appgrec/src/widgets/custom_buttons_sec.dart';

class PrizeFormBottomSheet extends StatefulWidget {
  final Function(String, String)? onSave;

  const PrizeFormBottomSheet({super.key, this.onSave});

  @override
  PrizeFormBottomSheetState createState() => PrizeFormBottomSheetState();
}

class PrizeFormBottomSheetState extends State<PrizeFormBottomSheet> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Función para crear el premio
  Future<void> _createPrize() async {
    if (_nameController.text.isEmpty || _descriptionController.text.isEmpty) {
      CustomSnackbar.showWarning(context, 'Todos los campos son requeridos.');
      return;
    }

    final String? backendUrl = dotenv.env['FRONTEND_URL'];
    if (backendUrl == null || backendUrl.isEmpty) {
      CustomSnackbar.showError(context, 'Error: FRONTEND_URL no está definida.');
      return;
    }

    final response = await http.post(
      Uri.parse('$backendUrl/api/prizes/create'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'name_prize': _nameController.text,
        'description_prize': _descriptionController.text,
      }),
    );

    if (response.statusCode == 201) {
      widget.onSave?.call(_nameController.text, _descriptionController.text);
      CustomSnackbar.showSuccess(context, 'Premio agregado correctamente.');
      Navigator.of(context).pop();
    } else {
      final jsonResponse = json.decode(response.body);
      CustomSnackbar.showError(context, jsonResponse['message']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // Cerrar el teclado al tocar fuera del formulario
      },
      child: Scaffold(
        body: SingleChildScrollView( // Permite que el contenido se desplace si el teclado aparece
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
                CustomTextFormField(
                  labelText: 'Nombre del Premio',
                  controller: _nameController,
                  icon: Icons.card_giftcard,
                ),
                const SizedBox(height: 10),
                CustomTextFormField(
                  labelText: 'Descripción del Premio',
                  controller: _descriptionController,
                  icon: Icons.description,
                  maxLines: null, // Campo de descripción se expande
                  keyboardType: TextInputType.multiline,
                  minLines: 3,
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
                      onPressed: _createPrize,
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
