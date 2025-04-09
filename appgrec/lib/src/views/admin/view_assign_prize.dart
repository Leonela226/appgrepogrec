import 'package:appgrec/src/widgets/custom_buttons_sec.dart'; 
import 'package:appgrec/src/widgets/custom_dropdownbottom.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:appgrec/src/widgets/custom_appbar.dart';
import 'package:appgrec/src/widgets/custom_drawer.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:appgrec/src/widgets/custom_snackbar.dart';
import 'package:appgrec/src/widgets/custom_paginated_table.dart';

class AssignPrizeScreen extends StatefulWidget {
  final int giveawayId;

  const AssignPrizeScreen({super.key, required this.giveawayId});

  @override
  AssignPrizeScreenState createState() => AssignPrizeScreenState();
}

class AssignPrizeScreenState extends State<AssignPrizeScreen> {
  int? selectedNumber2 = 1;
  String giveawayName = '';
  int? prizeCount;
  List<String> prizeNames = [];
  String? selectedPrize;

  String? baseUrl;
  List<Map<String, dynamic>> assignedPrizes = [];

  @override
  void initState() {
    super.initState();
    baseUrl = dotenv.env['FRONTEND_URL'];
    if (baseUrl == null || baseUrl!.isEmpty) {
      if (mounted) {
        CustomSnackbar.showError(context, 'Error: FRONTEND_URL no está definida.');
      }
      return;
    }
    _fetchGiveawayDetails();
    _fetchPrizes();
  }

  Future<void> _fetchGiveawayDetails() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/assign/giveaway/${widget.giveawayId}'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          giveawayName = data['name'];
          prizeCount = data['prize_count'];
        });
      } else {
        CustomSnackbar.showError(context, 'Error al cargar el sorteo');
      }
    } catch (error) {
      CustomSnackbar.showError(context, 'Error al obtener los detalles del sorteo: $error');
    }
  }

  Future<void> _fetchPrizes() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/assign/prizes'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          prizeNames = List<String>.from(data['data'].map((prize) => prize['name_prize']));
          // No asignar premios hasta que se presione "Asignar"
          assignedPrizes = []; // Inicializa la lista como vacía
 
        });
      } else {
        CustomSnackbar.showError(context, 'Error al cargar los premios');
      }
    } catch (error) {
      CustomSnackbar.showError(context, 'Error al obtener los premios: $error');
    }
  }

Future<void> _onAssign() async {
  if (selectedPrize != null) {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/assign/countPrizes/${widget.giveawayId}'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        int assignedFromDb = data['assignedPrizesCount']; // Desde backend
        int maxPrizes = prizeCount ?? 0;
        int assignedLocally = assignedPrizes.length;

        if ((assignedFromDb + assignedLocally) >= maxPrizes) {
          CustomSnackbar.showWarning(
              context, 'No se pueden asignar más premios. Ya se alcanzó el límite de $maxPrizes.');
          return;
        }

        // Verifica que el premio no esté repetido localmente
        bool prizeAlreadyUsed = assignedPrizes.any((prize) => prize['premio'] == selectedPrize);
        if (prizeAlreadyUsed) {
          CustomSnackbar.showWarning(context, 'Este premio ya ha sido asignado localmente, elija otro.');
          return;
        }

        // Asegura que el orden esté en secuencia. Si no, asigna el siguiente orden disponible
        if (assignedPrizes.isEmpty) {
          selectedNumber2 = 1; // El primer premio siempre tendrá el orden 1
        } else {
          // Encontramos el próximo orden disponible
          List<int> usedOrders = assignedPrizes.map((prize) => prize['orden'] as int).toList();
          usedOrders.sort();
          
          // El próximo orden debe ser el siguiente número en la secuencia
          selectedNumber2 = usedOrders.last + 1;
        }

        // Agrega el premio localmente
        setState(() {
          assignedPrizes.add({
            'premio': selectedPrize,
            'orden': selectedNumber2,
          });
          selectedPrize = null;
          selectedNumber2 = null; // Reinicia el número de orden
        });

        CustomSnackbar.showSuccess(context, 'Premio asignado exitosamente.');
      } else {
        CustomSnackbar.showError(context, 'Error al verificar la cantidad de premios asignados.');
      }
    } catch (error) {
      CustomSnackbar.showError(context, 'Error: $error');
    }
  } else {
    CustomSnackbar.showWarning(context, 'Por favor, seleccione un premio.');
  }
}


  // Función para el botón Guardar
Future<void> _onSave() async {
  if (assignedPrizes.isEmpty) {
    CustomSnackbar.showWarning(context, 'No hay premios asignados.');
    return;
  }

  try {
    // Preparamos los datos para enviarlos al backend
    List<Map<String, dynamic>> prizesToSave = assignedPrizes.map((prize) {
      return {
        'prize_id': prize['premio'],  // Asumimos que 'premio' contiene el ID del premio
        'rank': prize['orden'],  // Asumimos que 'orden' es el rank
      };
    }).toList();

    // Enviamos la solicitud POST al servidor
    final response = await http.post(
      Uri.parse('$baseUrl/api/assign/save'),  // El endpoint en tu backend
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'id_giveaway': widget.giveawayId,
        'assignedPrizes': prizesToSave,
      }),
    );

    // Verificamos la respuesta del servidor
    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      CustomSnackbar.showSuccess(context, data['message']);
      // Si los premios se guardan exitosamente, puedes limpiar la lista o actualizar el UI
      setState(() {
        assignedPrizes.clear();  // Limpiar los premios asignados localmente
      });
    } else {
      final data = json.decode(response.body);
      CustomSnackbar.showError(context, data['message']);
    }
  } catch (error) {
    CustomSnackbar.showError(context, 'Error al guardar los premios: $error');
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(),
      appBar: const CustomAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Alineación a la izquierda
          children: [
            const SizedBox(height: 15),
            Center(
              child: const Text(
                'Asignación de Premios',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'TitilliumWeb',
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 15),

            // Card para mostrar el nombre del sorteo y los premios asignados
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    giveawayName.isNotEmpty
                        ? Row(
                            children: [
                              const Icon(Icons.card_giftcard, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Sorteo: $giveawayName',
                                style: const TextStyle(
                                  fontFamily: 'TitilliumWeb',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          )
                        : const Text(
                            'Cargando...',
                            style: TextStyle(
                              fontFamily: 'TitilliumWeb',
                              fontSize: 16,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                    const SizedBox(height: 10),
                    prizeCount != null
                        ? Row(
                            children: [
                              const Icon(Icons.emoji_events, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Premios a asignar: $prizeCount',
                                style: const TextStyle(
                                  fontFamily: 'TitilliumWeb',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ],
                          )
                        : const SizedBox(),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
            // Dropdown para el premio
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9, // 80% del ancho de la pantalla
                child: CustomDropdownButton<String>(
                  labelText: 'Seleccione el Premio',
                  items: prizeNames,
                  selectedValue: selectedPrize,
                  onChanged: (newValue) {
                    setState(() {
                      selectedPrize = newValue;
                    });
                  },
                  itemTextStyle: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'TitilliumWeb',
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 15.0),
              child: Row(
                children: [
                  const SizedBox(width: 0.5), // Espacio entre el dropdown y el botón
                  // Botón de asignación con CustomBottonSec
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.9, // Ancho igual al 90
                    child: CustomBottonSec(
                      text: 'Asignar',
                      onPressed: _onAssign,  // Aquí usamos la nueva función
                      backgroundColor: const Color(0xFF434244), // Color 
                      paddingHorizontal: 12.0, // Reducir padding horizontal
                      paddingVertical: 6.0,  // Reducir padding vertical
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 5),
            // Aquí se agrega el CustomPaginatedTable
            CustomPaginatedTable(
              columns: [
                DataColumn(label: Text('Premios')),
                DataColumn(label: Text('Orden de Asignación')),
              ],
              dataSource: AssignedPrizesData(assignedPrizes),
              headerText: 'Detalles de asignación',
            ),

            const SizedBox(height: 20),
            // Botón de Guardar
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.30, // Ancho reducido al 25% de la pantalla
              child: CustomBottonSec(
                text: 'Guardar',
                onPressed: _onSave,
                paddingHorizontal: 12.0,
                paddingVertical: 6.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// DataTableSource para los datos de la tabla
class AssignedPrizesData extends DataTableSource {
  final List<Map<String, dynamic>> _data;

  AssignedPrizesData(this._data);

  @override
  DataRow getRow(int index) {
    assert(index >= 0 && index < _data.length);
    final row = _data[index];
    return DataRow(cells: [
      DataCell(
        Align(  // Centramos el contenido de la celda
          child: Text(
            row['premio'] ?? '', // Garantizamos que el valor sea un String
            textAlign: TextAlign.left,  // Alineación al centro
            style: TextStyle(
              fontFamily: 'TitilliumWeb',
              fontWeight: FontWeight.w300, // Light
              fontSize: 12,
            ),
          ),
        ),
      ),
      DataCell(
        Align(  // Centramos el contenido de la celda
          child: Text(
            row['orden'] != null ? row['orden'].toString() : '0', // Convertimos el int a String
            textAlign: TextAlign.left,  // Alineación al centro
            style: TextStyle(
              fontFamily: 'TitilliumWeb',
              fontWeight: FontWeight.normal, // Regular
              fontSize: 13,
            ),
          ),
        ),
      ),
    ]);
  }

  @override
  int get rowCount => _data.length;

  @override
  int get selectedRowCount => 0;

  @override
  bool get isRowCountApproximate => false;  // Aquí implementamos el getter
}
