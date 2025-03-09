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
      CustomSnackbar.showSnackBar(context, 'Error: FRONTEND_URL no está definida.');
      return;
    }

    try {
      final response = await http.get(Uri.parse('$baseUrl/api/carousel/all'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          imageUrls = List<String>.from(data['data'].map((item) => item['url_carousel_image']));
        });
      } else {
        throw Exception('Error al cargar las imágenes');
      }
    } catch (e) {
      CustomSnackbar.showSnackBar(context, 'Error al cargar las imágenes: $e');
    }
  }

  // Función para seleccionar la imagen y enviarla al backend
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) {
      CustomSnackbar.showSnackBar(context, 'No se seleccionó ninguna imagen');
      return;
    }

    print("Imagen seleccionada: ${pickedFile.path}"); // Verifica la imagen seleccionada

    final String? backendUrl = dotenv.env['FRONTEND_URL']; 
    if (backendUrl == null || backendUrl.isEmpty) {
      CustomSnackbar.showSnackBar(context, 'Error: FRONTEND_URL no está definida.');
      return;
    }

    var request = http.MultipartRequest('POST', Uri.parse('$backendUrl/api/carousel/create'));

    request.files.add(
      await http.MultipartFile.fromPath(
        'carousel_image',
        pickedFile.path,
        contentType: MediaType('image', 'jpeg'), // Asegura que se envíe como image/jpeg
      ),
    );

    // Agregar los otros campos requeridos
    request.fields['title_carousel_image'] = 'Imagen';
    request.fields['description_carousel_image'] = 'Imagen subida desde Flutter';

    try {
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      
      if (response.statusCode == 201) {
        var jsonResponse = json.decode(responseBody);
        String newImageUrl = jsonResponse['data']['url_carousel_image'];

        setState(() {
          imageUrls.add(newImageUrl);
        });

        CustomSnackbar.showSnackBar(context, 'Imagen subida correctamente');
      } else {
        print("Error en la respuesta del backend: $responseBody");
        CustomSnackbar.showSnackBar(context, 'Error al subir la imagen: ${response.statusCode}');
      }
    } catch (e) {
      CustomSnackbar.showSnackBar(context, 'Error en la subida: $e');
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
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: ElevatedButton(
              onPressed: _pickImage, // Llamar a la función de selección de imagen
              child: const Text('Agregar'),
            ),
          ),
        ],
      ),
    );
  }
}
