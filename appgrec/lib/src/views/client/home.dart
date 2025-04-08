import 'package:appgrec/src/widgets/custom_appbar.dart';
import 'package:appgrec/src/widgets/custom_bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:appgrec/src/widgets/custom_carousel.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  ClientHomeScreenState createState() => ClientHomeScreenState();
}

class ClientHomeScreenState extends State<ClientHomeScreen> {
  List<String> imageUrls = [];
  late io.Socket socket;

  @override
  void initState() {
    super.initState();
    fetchCarouselImages();
    setupSocket();
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
            // Concatenar la URL base con la ruta de la imagen
            imageUrls = List<String>.from(data['data'].map((item) => '$baseUrl/uploads/carousel_images/${item['url_carousel_image']}'));
          });
        }
      } else {
        throw Exception('Error al cargar las imágenes');
      }
    } catch (e) {
      //print('Error al cargar imágenes: $e');
    }
  }

  void setupSocket() {
    final String? baseUrl = dotenv.env['FRONTEND_URL'];
    if (baseUrl == null || baseUrl.isEmpty) return;

    socket = io.io(baseUrl, <String, dynamic>{
      "transports": ["websocket"],
      "autoConnect": true,
    });

    socket.onConnect((_) {
      //print("🟢 Conectado a WebSocket");
    });

    socket.on("carouselUpdated", (data) {
      //print("🔄 Actualización recibida: ${data['message']}");
      fetchCarouselImages();
    });

    socket.onDisconnect((_) {
      //print("🔴 Desconectado de WebSocket");
    });
  }

  @override
  void dispose() {
    socket.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(), // Se usa el AppBar personalizado
      body: Column(
        children: [
          const SizedBox(height: 20),
          CustomCarousel(imageUrls: imageUrls), // Carrusel primero
          const SizedBox(height: 20),
          // Alineación a la izquierda con el color #ff0000
          Align(
            alignment: Alignment.centerLeft, // Alineación a la izquierda
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20), // Opcional: Agrega un poco de espacio en los laterales
              child: Text(
                'Bienvenido de Nuevo',
                style: TextStyle(
                  fontSize: 24,
                  fontFamily: 'TitilliumWeb', // Aplicar la fuente TitilliumWeb
                  fontWeight: FontWeight.w600, // SemiBold
                  color: Color(0xFFFF0000), // Color del texto #ff0000
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(), // Aquí se agrega el CustomBottomNavBar
    );
  }
}
