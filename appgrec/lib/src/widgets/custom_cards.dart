import 'package:appgrec/src/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flip_card/flip_card.dart';  // Importar flip_card

class CustomCardScreen extends StatefulWidget {
  final int userRole; // 2 = cliente, 1 = administrador

  const CustomCardScreen({super.key, required this.userRole});

  @override
  CustomCardScreenState createState() => CustomCardScreenState();
}

class CustomCardScreenState extends State<CustomCardScreen> {
  List<Map<String, dynamic>> cards = [];

  @override
  void initState() {
    super.initState();
    _fetchGiveaways();
  }

  Future<void> _fetchGiveaways() async {
    final String? baseUrl = dotenv.env['FRONTEND_URL'];
    if (baseUrl == null || baseUrl.isEmpty) {
      if (mounted) {
        CustomSnackbar.showError(context, 'Error: BACKEND_URL no está definida.');
      }
      return;
    }

    try {
      final response = await http.get(Uri.parse('$baseUrl/api/cards/active'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          cards = List<Map<String, dynamic>>.from(data.map((giveaway) => {
                'imageUrl': giveaway['imageUrl'] != null
                    ? '$baseUrl/uploads/giveaway_images/${giveaway['imageUrl']}'
                    : '',
                'title': giveaway['title'],
                'start': giveaway['startParticipation'],
                'end': giveaway['endParticipation'],
                'drawDate': giveaway['drawDate'],
                'prizes': (giveaway['prizes'] is List)
                    ? giveaway['prizes'].join(', ')
                    : 'Sin premios',
                'status': giveaway['status'] ?? 'Desconocido',
                'description': giveaway['description'] ?? 'Sin descripción', // Agregar la descripción
              }));
        });
      } else {
        CustomSnackbar.showError(context, 'Error al cargar los sorteos');
      }
    } catch (e) {
      CustomSnackbar.showError(context, 'Error en la petición: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true, // <-- Importante para que el scroll funcione en la pantalla 
      physics: const NeverScrollableScrollPhysics(), // <-- Para que no haga scroll interno
      padding: const EdgeInsets.all(12.0),
      itemCount: cards.length,
      itemBuilder: (context, index) {
        final item = cards[index];

        // Crear una clave única para cada tarjeta
        final GlobalKey<FlipCardState> flipCardKey = GlobalKey<FlipCardState>();

        return Container(
          margin: const EdgeInsets.only(bottom: 16.0),
          child: FlipCard(
            key: flipCardKey,  // Asociar la clave única a cada tarjeta
            direction: FlipDirection.HORIZONTAL,
            front: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 170, // Puedes ajustar la altura aquí
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                      ),
                    ),
                    child: item['imageUrl'] == ''
                        ? const Icon(Icons.broken_image, size: 50, color: Colors.grey)
                        : ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(15),
                              topRight: Radius.circular(15),
                            ),
                            child: Image.network(
                              item['imageUrl']!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              alignment: Alignment.center,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF0000)),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.error, color: Colors.red),
                            ),
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${item['title']}', style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'TitilliumWeb', fontSize: 22)),
                        const SizedBox(height: 4),
                        Text('Inicio de participación: ${item['start']}', style: const TextStyle(fontWeight: FontWeight.w400, fontFamily: 'TitilliumWeb', fontSize: 14)),
                        Text('Fin de participación: ${item['end']}', style: const TextStyle(fontFamily: 'TitilliumWeb', fontSize: 14)),
                        Text('Fecha del sorteo: ${item['drawDate']}', style: const TextStyle(fontFamily: 'TitilliumWeb', fontSize: 14)),
                        Text('Premios: ${item['prizes']}', style: const TextStyle(fontFamily: 'TitilliumWeb', fontSize: 14)),
                        Text('Estado: ${item['status']}', style: TextStyle(fontFamily: 'TitilliumWeb', fontSize: 14, color: item['status'].toString().toLowerCase() == 'activo' ? const Color(0xFF15A81A) : Colors.black)),
                      ],
                    ),
                  ),
                  if (widget.userRole == 2)
                    Padding(
                      padding: const EdgeInsets.only(left: 12, right: 12, bottom: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                             onPressed: () => Navigator.pushNamed(context, '/client_scan'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF0000),
                              foregroundColor: Colors.white,
                            ),
                            child: const Text(
                              'Escanear',
                              style: TextStyle(fontSize: 14, fontFamily: 'TitilliumWeb', fontWeight: FontWeight.w600),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              // Volteamos la tarjeta al presionar "Ver más"
                              flipCardKey.currentState?.toggleCard();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF0000),
                              foregroundColor: Colors.white,
                            ),
                            child: const Text(
                              'Ver más',
                              style: TextStyle(fontSize: 14, fontFamily: 'TitilliumWeb', fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            back: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Detalles del Sorteo', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'TitilliumWeb')),
                    const SizedBox(height: 12),
                    Text('Detalles: ${item['description']}', style: const TextStyle(fontSize: 16, fontFamily: 'TitilliumWeb')),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
