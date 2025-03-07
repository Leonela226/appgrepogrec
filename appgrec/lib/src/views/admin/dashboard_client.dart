import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';  // Para parsear el JSON
import 'package:appgrec/src/widgets/custom_carousel.dart'; // Asegúrate de tener la ruta correcta
import 'package:appgrec/src/widgets/custom_appbar.dart';

class DashboardAdminClientScreen extends StatefulWidget {
  const DashboardAdminClientScreen({super.key});

  @override
  _DashboardAdminClientScreenState createState() => _DashboardAdminClientScreenState();
}

class _DashboardAdminClientScreenState extends State<DashboardAdminClientScreen> {
  List<String> imageUrls = [];

  @override
  void initState() {
    super.initState();
    fetchImages();
  }

  Future<void> fetchImages() async {
    try {
      final response = await http.get(Uri.parse('FRONTEND_URL/api/carousel/images'));  // Ajusta la URL según tu backend

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['images'] != null) {
          setState(() {
            imageUrls = List<String>.from(data['images'].map((image) => image['url']));
          });
        } else {
          // Si no hay imágenes, puedes usar la URL por defecto
          setState(() {
            imageUrls = [data['default_url']];
          });
        }
      } else {
        throw Exception('Error al obtener las imágenes');
      }
    } catch (e) {
      print('Error al cargar las imágenes: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Column(
        children: [
          // Aquí integras el CustomCarousel
          CustomCarousel(imageUrls: imageUrls),

          // Resto de tu contenido
          const Expanded(
            child: Center(
              child: Text(
                '¡Hola, DashboardAdminClientScreen!',
                style: TextStyle(fontSize: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
