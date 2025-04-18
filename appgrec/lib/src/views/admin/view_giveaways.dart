import 'dart:convert';
import 'package:appgrec/src/views/admin/giveaway_form_bottom_sheet.dart';
import 'package:appgrec/src/views/admin/view_assign_prize.dart';
import 'package:appgrec/src/widgets/custom_buttons_sec.dart';
import 'package:appgrec/src/widgets/custom_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:appgrec/src/widgets/custom_appbar.dart';
import 'package:appgrec/src/widgets/custom_drawer.dart';
import 'package:appgrec/src/widgets/custom_snackbar.dart';

class ViewGiveawaysScreen extends StatefulWidget {
  const ViewGiveawaysScreen({super.key});

  @override
  ViewGiveawaysScreenState createState() => ViewGiveawaysScreenState();
}

class ViewGiveawaysScreenState extends State<ViewGiveawaysScreen> {
  final int itemsPerPage = 5;
  int currentPage = 1;
  List<Map<String, dynamic>> giveaways = [];
  List<Map<String, dynamic>> filteredGiveaways = [];
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadGiveaways();
  }

  // Carga los sorteos desde el servidor
  Future<void> _loadGiveaways() async {
    final String? baseUrl = dotenv.env['FRONTEND_URL'];
    if (baseUrl == null || baseUrl.isEmpty) {
      if (mounted) {
        CustomSnackbar.showError(context, 'Error: FRONTEND_URL no está definida.');
      }
      return;
    }

    try {
      final response = await http.get(Uri.parse('$baseUrl/api/giveaways/all'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          if (data['data'] is List) {
            setState(() {
              giveaways = List<Map<String, dynamic>>.from(data['data']);
              giveaways = giveaways.map((giveaway) {
                return {
                  'id': giveaway['id_giveaway'],
                  'name': giveaway['name_giveaway'] ?? 'Nombre no disponible',
                  'prize_count': giveaway['prize_count'] ?? 0,
                  'start_date': giveaway['start_date_giveaway'] ?? 'No disponible',
                  'end_date': giveaway['end_date_giveaway'] ?? 'No disponible',
                  'draw_date': giveaway['draw_date_giveaway'] ?? 'No disponible',
                  'status': giveaway['status_giveaway'] ?? 'No disponible',
                  'code_giveaway': giveaway['code_giveaway'] ?? 'No disponible',
                };
              }).toList();
              filteredGiveaways = List.from(giveaways);
              isLoading = false;
            });
          } else {
            CustomSnackbar.showError(context, 'Error: los datos de los sorteos no son válidos.');
            setState(() {
              isLoading = false;
            });
          }
        }
      } else {
        throw Exception('Error al cargar los sorteos');
      }
    } catch (e) {
      if (mounted) {
        CustomSnackbar.showError(context, 'Error al cargar los sorteos: $e');
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // Filtra los sorteos por nombre
  void _filterGiveaways(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredGiveaways = List.from(giveaways);
      } else {
        filteredGiveaways = giveaways
            .where((giveaway) =>
                giveaway['name'].toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
      currentPage = 1;
    });
  }

  // Método para mostrar el modal y actualizar la lista al crear un sorteo
  void _showCreateGiveawayModal() async {
    final newGiveaway = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const GiveawayModal(),
    );

    if (newGiveaway != null) {
      await _loadGiveaways();  // Llama nuevamente a la función de carga y espera a que se complete
    }
  }

  // Método para obtener el color del círculo según el estado
  Color _getStatusColor(String status) {
    if (status == 'activo') {
      return Colors.green;
    } else if (status == 'pendiente') {
      return Colors.yellow;
    } else {
      return Colors.grey; // Si el estado no es "activo" ni "pendiente"
    }
  }

  @override
  Widget build(BuildContext context) {
    int totalPages = (filteredGiveaways.length / itemsPerPage).ceil();
    int startIndex = (currentPage - 1) * itemsPerPage;
    int endIndex = (startIndex + itemsPerPage).clamp(0, filteredGiveaways.length);
    List<Map<String, dynamic>> visibleGiveaways = filteredGiveaways.sublist(startIndex, endIndex);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        drawer: const CustomDrawer(),
        appBar: const CustomAppBar(),
        body: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Text(
                'Gestión de Sorteos',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'TitilliumWeb', // Fuente aplicada
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              CustomTextFormField(
                labelText: 'Buscar sorteo',
                icon: Icons.search,
                controller: _searchController,
                onChanged: _filterGiveaways,
              ),
              const SizedBox(height: 10),
              isLoading
                  ? const Center(child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF0000)), // Usando el color rojo
                  ))
                  : filteredGiveaways.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Text(
                              'Aún no hay sorteos creados',
                              style: TextStyle(
                                fontSize: 18, 
                                fontWeight: FontWeight.bold, 
                                color: Colors.grey,
                                fontFamily: 'TitilliumWeb', // Fuente aplicada
                              ),
                            ),
                          ),
                        )
                      : Expanded(  // Mover la lista a un Expanded para ocupar el espacio disponible
                          child: ListView.builder(
                            itemCount: visibleGiveaways.length,
                            itemBuilder: (context, index) {
                              final giveaway = visibleGiveaways[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 10),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4), // Agregar padding horizontal
                                  title: Text(
                                    giveaway['name'],
                                    style: const TextStyle(
                                      fontFamily: 'TitilliumWeb',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16 // Fuente aplicada
                                    ),
                                  ),
                                  subtitle: DefaultTextStyle(
                                    style: const TextStyle(
                                      fontFamily: 'TitilliumWeb', // Fuente aplicada
                                      fontWeight: FontWeight.w300,
                                      fontSize: 14, // Tamaño común
                                      color: Colors.black, // Color común
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Premios a sortear: ${giveaway['prize_count']}'),
                                        Text('Inicio participación: ${giveaway['start_date']}'),
                                        Text('Fin participación: ${giveaway['end_date']}'),
                                        Text('Fecha del sorteo: ${giveaway['draw_date']}'),
                                        Text('Estado: ${giveaway['status']}'),
                                        Text('Código: ${giveaway['code_giveaway']}'),
                                      ],
                                    ),
                                  ),
                                  trailing: SizedBox(
                                    width: 100, // Ajustar tamaño del botón
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          final int giveawayId = giveaway['id'];  // Obtienes el id del sorteo
                                           Navigator.push(
                                            context,
                                             MaterialPageRoute(builder: (context) => AssignPrizeScreen(giveawayId: giveawayId)),  
                                           );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color(0xFF434244), // Cambiar el color del fondo
                                          textStyle: const TextStyle(
                                            fontFamily: 'TitilliumWeb', // Cambiar la fuente del texto
                                            fontWeight: FontWeight.w300, // Peso de la fuente
                                            fontSize: 10,
                                          ),
                                          foregroundColor: Colors.white, // Asegurarse de que el texto sea blanco
                                          padding: const EdgeInsets.symmetric(horizontal: 14), // Evita que el botón se expanda
                                        ),
                                        child: const Text(
                                          'Asignar premio',
                                          overflow: TextOverflow.ellipsis, // Asegura que el texto no se desborde
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Círculo de color según el estado
                                  leading: CircleAvatar(
                                    backgroundColor: _getStatusColor(giveaway['status']),
                                    radius: 8,  // Radio reducido para hacerlo más pequeño
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 14.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: currentPage > 1 ? () => setState(() => currentPage--) : null,
                    ),
                    Text(
                      'Página $currentPage de $totalPages',
                      style: const TextStyle(
                        fontFamily: 'TitilliumWeb', // Fuente aplicada
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward),
                      onPressed: currentPage < totalPages ? () => setState(() => currentPage++) : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              CustomBottonSec(
                text: 'Agregar',
                onPressed: _showCreateGiveawayModal, // Abre el modal para crear un sorteo
              ),
            ],
          ),
        ),
      ),
    );
  }
}


