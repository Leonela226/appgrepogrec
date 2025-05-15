import 'package:appgrec/src/widgets/custom_cards.dart';
import 'package:flutter/material.dart';
import 'package:appgrec/src/widgets/custom_appbar.dart';
import 'package:appgrec/src/widgets/custom_bottom_nav_bar.dart';
import 'package:appgrec/src/widgets/custom_carousel.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  ClientHomeScreenState createState() => ClientHomeScreenState();
}

class ClientHomeScreenState extends State<ClientHomeScreen> {
  List<String> imageUrls = [];

  @override
  void initState() {
    super.initState();
    fetchCarouselImages();
  }

  Future<void> fetchCarouselImages() async {
    final String? baseUrl = dotenv.env['FRONTEND_URL'];
    if (baseUrl == null || baseUrl.isEmpty) return;

    try {
      final response = await http.get(Uri.parse('$baseUrl/api/carousel/all'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            imageUrls = List<String>.from(
              data['data'].map(
                (item) => '$baseUrl/uploads/carousel_images/${item['url_carousel_image']}',
              ),
            );
          });
        }
      } else {
        throw Exception('Error al cargar las imágenes');
      }
    } catch (e) {
      // Manejo de error si es necesario
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),
            CustomCarousel(
              imageUrls: imageUrls,
              onDelete: (_) {},
              onSelect: (_) {},
            ),
            const SizedBox(height: 5),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                '¡Bienvenido de Nuevo!',
                style: TextStyle(
                  fontSize: 25,
                  fontFamily: 'TitilliumWeb',
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFF0000),
                  shadows: [
                    Shadow(
                      offset: Offset(1.1, 1.1),
                      blurRadius: 3,
                      color: Colors.black26,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 194, 190, 192),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.qr_code_scanner, color: Colors.black, size: 30),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Escanea tus facturas para más\nprobabilidad de ganar',
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'TitilliumWeb',
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: CustomCardScreen(userRole: 2),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }
}
