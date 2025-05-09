import 'package:appgrec/src/widgets/custom_buttons_sec.dart';
import 'package:appgrec/src/widgets/custom_cards.dart';
import 'package:appgrec/src/widgets/custom_drawer.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:appgrec/src/widgets/custom_carousel.dart';
import 'package:appgrec/src/widgets/custom_appbar.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:appgrec/src/widgets/custom_snackbar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';

class DashboardAdminClientScreen extends StatefulWidget {
  const DashboardAdminClientScreen({super.key});

  @override
  DashboardAdminClientScreenState createState() => DashboardAdminClientScreenState();
}

class DashboardAdminClientScreenState extends State<DashboardAdminClientScreen> {
  List<String> imageUrls = [];
  final ImagePicker _picker = ImagePicker();
  int? selectedIndex;

  @override
  void initState() {
    super.initState();
    fetchCarouselImages();
  }

  Future<void> fetchCarouselImages() async {
    final String? baseUrl = dotenv.env['FRONTEND_URL'];
    if (baseUrl == null || baseUrl.isEmpty) {
      if (mounted) {
        CustomSnackbar.showError(context, 'Error: FRONTEND_URL no está definida.');
      }
      return;
    }

    try {
      final response = await http.get(Uri.parse('$baseUrl/api/carousel/all'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            imageUrls = List<String>.from(
              data['data'].map((item) => '$baseUrl/uploads/carousel_images/${item['url_carousel_image']}'),
            );
          });
        }
      } else {
        throw Exception('Error al cargar las imágenes');
      }
    } catch (e) {
      if (mounted) {
        CustomSnackbar.showError(context, 'Error al cargar las imágenes: $e');
      }
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) {
      if (mounted) {
        CustomSnackbar.showWarning(context, 'No se seleccionó ninguna imagen');
      }
      return;
    }

    final String? backendUrl = dotenv.env['FRONTEND_URL'];
    if (backendUrl == null || backendUrl.isEmpty) {
      if (mounted) {
        CustomSnackbar.showError(context, 'Error: FRONTEND_URL no está definida.');
      }
      return;
    }

    var request = http.MultipartRequest('POST', Uri.parse('$backendUrl/api/carousel/create'));

    request.files.add(
      await http.MultipartFile.fromPath(
        'carousel_image',
        pickedFile.path,
        contentType: MediaType('image', 'jpeg'),
      ),
    );

    try {
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      
      if (response.statusCode == 201) {
        var jsonResponse = json.decode(responseBody);
        String newImageUrl = jsonResponse['data']['url_carousel_image'];

        if (mounted) {
          setState(() {
            imageUrls.add('$backendUrl/uploads/carousel_images/$newImageUrl');
          });
          CustomSnackbar.showSuccess(context, 'Imagen subida correctamente');
        }
      } else {
        if (mounted) {
          CustomSnackbar.showError(context, 'Error al subir la imagen: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (mounted) {
        CustomSnackbar.showError(context, 'Error en la subida: $e');
      }
    }
  }

  Future<void> _deleteImage(int index) async {
    final String? backendUrl = dotenv.env['FRONTEND_URL'];
    if (backendUrl == null || backendUrl.isEmpty) {
      if (mounted) {
        CustomSnackbar.showError(context, 'Error: FRONTEND_URL no está definida.');
      }
      return;
    }

    try {
      final imageUrl = imageUrls[index];
      final imageName = imageUrl.split('/').last;

      final response = await http.delete(
        Uri.parse('$backendUrl/api/carousel/delete/$imageName'),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            imageUrls.removeAt(index);
            selectedIndex = null;
          });
        }
        CustomSnackbar.showSuccess(context, 'Imagen eliminada correctamente');
      } else {
        CustomSnackbar.showError(context, 'Error al eliminar la imagen: ${response.statusCode}');
      }
    } catch (e) {
      CustomSnackbar.showError(context, 'Error al eliminar la imagen: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(),
      appBar: const CustomAppBar(),
      body: SingleChildScrollView(   // Scroll único para todo el contenido
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const Center(
                child: Text(
                  'Gestión de Vista de Cliente',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'TitilliumWeb',
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              CustomCarousel(
                imageUrls: imageUrls,
                onDelete: _deleteImage,
                onSelect: (index) {
                  setState(() {
                    selectedIndex = index;
                  });
                },
                selectedIndex: selectedIndex,
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomBottonSec(
                    text: 'Agregar',
                    onPressed: _pickImage,
                  ),
                  const SizedBox(width: 10),
                  CustomBottonSec(
                    text: 'Eliminar',
                    onPressed: () {
                      if (selectedIndex == null) {
                        CustomSnackbar.showWarning(context, 'Por favor, selecciona una imagen para eliminar.');
                        return;
                      }
                      _deleteImage(selectedIndex!);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              CustomCardScreen(userRole: 1),  //  ahora fluye con el Scroll
            ],
          ),
        ),
      ),
    );
  }
}
