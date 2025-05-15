import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class PrizeFormBottomSheet extends StatefulWidget {
  final Function(String, String, File?) onSave;

  const PrizeFormBottomSheet({super.key, required this.onSave});

  @override
  PrizeFormBottomSheetState createState() => PrizeFormBottomSheetState();
}

class PrizeFormBottomSheetState extends State<PrizeFormBottomSheet> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  File? _imageFile;

  // Función para seleccionar una imagen
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(  // Agregado para permitir el desplazamiento
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Datos del Premio",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            // Seleccionar Imagen
            _imageFile == null
                ? GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 100,
                      width: 100,
                      color: Colors.grey[300],
                      child: const Icon(Icons.camera_alt, size: 40),
                    ),
                  )
                : Image.file(
                    _imageFile!,
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                  ),
            const SizedBox(height: 10),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nombre del Premio',
                icon: Icon(Icons.card_giftcard),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Descripción del Premio',
                icon: Icon(Icons.description),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Cerrar el BottomSheet
                  },
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_nameController.text.isNotEmpty &&
                        _descriptionController.text.isNotEmpty) {
                      widget.onSave(
                        _nameController.text,
                        _descriptionController.text,
                        _imageFile,
                      );
                      Navigator.of(context).pop(); // Cerrar el BottomSheet
                    }
                  },
                  child: const Text('Agregar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
