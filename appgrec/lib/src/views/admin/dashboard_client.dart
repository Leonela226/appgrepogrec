import 'package:appgrec/src/widgets/custom_buttons_sec.dart';
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
  DashboardAdminClientScreenState createState() =>
      DashboardAdminClientScreenState();
}

class DashboardAdminClientScreenState extends State<DashboardAdminClientScreen> {
  List<String> imageUrls = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    fetchCarouselImages();
  }

  // Función para cargar las imágenes desde el servidor
  Future<void> fetchCarouselImages() async {
    final String? baseUrl = dotenv.env['FRONTEND_URL'];
    if (baseUrl == null || baseUrl.isEmpty) {
      if (mounted) {
        CustomSnackbar.showSnackBar(context, 'Error: FRONTEND_URL no está definida.');
      }
      return;
    }

    try {
      final response = await http.get(Uri.parse('$baseUrl/api/carousel/all'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            imageUrls = List<String>.from(data['data'].map((item) => item['url_carousel_image']));
          });
        }
      } else {
        throw Exception('Error al cargar las imágenes');
      }
    } catch (e) {
      if (mounted) {
        CustomSnackbar.showSnackBar(context, 'Error al cargar las imágenes: $e');
      }
    }
  }

  // Función para seleccionar la imagen y enviarla al backend
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) {
      if (mounted) {
        CustomSnackbar.showSnackBar(context, 'No se seleccionó ninguna imagen');
      }
      return;
    }

    final String? backendUrl = dotenv.env['FRONTEND_URL']; 
    if (backendUrl == null || backendUrl.isEmpty) {
      if (mounted) {
        CustomSnackbar.showSnackBar(context, 'Error: FRONTEND_URL no está definida.');
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

    request.fields['title_carousel_image'] = 'Imagen';
    request.fields['description_carousel_image'] = 'Imagen subida desde Flutter';

    try {
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      
      if (response.statusCode == 201) {
        var jsonResponse = json.decode(responseBody);
        String newImageUrl = jsonResponse['data']['url_carousel_image'];

        if (mounted) {
          setState(() {
            imageUrls.add(newImageUrl);
          });
          CustomSnackbar.showSnackBar(context, 'Imagen subida correctamente');
        }
      } else {
        if (mounted) {
          CustomSnackbar.showSnackBar(context, 'Error al subir la imagen: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (mounted) {
        CustomSnackbar.showSnackBar(context, 'Error en la subida: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
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
          CustomCarousel(imageUrls: imageUrls), // Pasando las URLs al carrusel
          SizedBox(height: 20), // Añadimos un espacio entre el carrusel y los botones
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Botón "Agregar"
                CustomBottonSec(
                  text: 'Agregar',
                  onPressed: _pickImage, // Llamar a la función de selección de imagen
                ),
                SizedBox(width: 10), // Espacio entre los botones
                // Botón "Editar"
                CustomBottonSec(
                  text: 'Editar',
                  onPressed: () {
                    // Acción del botón "Editar"
                  },

                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
