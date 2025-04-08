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
  /*        // Simulación de datos asignados para la tabla
          assignedPrizes = List.generate(prizeNames.length, (index) {
            return {'premio': prizeNames[index], 'orden': index + 1};
          });*/
        });
      } else {
        CustomSnackbar.showError(context, 'Error al cargar los premios');
      }
    } catch (error) {
      CustomSnackbar.showError(context, 'Error al obtener los premios: $error');
    }
  }

  //Función para pasar datos al paginated table y restringir premios asignados 
Future<void> _onAssign() async {
  if (selectedPrize != null && selectedNumber2 != null) {
    try {
      // Obtener la cantidad de premios asignados para este sorteo
      final response = await http.get(Uri.parse('$baseUrl/api/assign/countPrizes/${widget.giveawayId}'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        int assignedPrizesCount = data['assignedPrizesCount'];
        int maxPrizes = prizeCount ?? 0; // Asegúrate de tener el número máximo de premios

        // Verificar si se puede asignar más premios
        if (assignedPrizesCount >= maxPrizes) {
          CustomSnackbar.showError(context, 'No se pueden asignar más premios. El sorteo ya tiene $maxPrizes premios asignados.');
          return;
        }

        // Si aún se pueden asignar más premios, agregarlos a la lista
        setState(() {
          assignedPrizes.add({
            'premio': selectedPrize,
            'orden': selectedNumber2,
          });
        });

        // Limpiar los dropdowns después de la asignación si es necesario
        setState(() {
          selectedPrize = null;
          selectedNumber2 = 1; // Valor por defecto
        });

        // Mostrar un mensaje de éxito
        CustomSnackbar.showSuccess(context, 'Premio asignado exitosamente.');
      } else {
        CustomSnackbar.showError(context, 'Error al verificar la cantidad de premios asignados');
      }
    } catch (error) {
      CustomSnackbar.showError(context, 'Error al obtener la cantidad de premios asignados: $error');
    }
  } else {
    CustomSnackbar.showError(context, 'Por favor, seleccione un premio y un orden.');
  }
}

  // Función para el botón Guardar
  void _onSave() {
    // Aquí puedes agregar la lógica para guardar los datos
    CustomSnackbar.showSuccess(context, 'Datos guardados exitosamente.');
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
                    fontSize: 12,
                    fontFamily: 'TitilliumWeb',
                    color: Colors.black,
                  ),
                ),
              ),
            ),

            // Segundo Dropdown (Orden) y botón al lado
            Padding(
              padding: const EdgeInsets.only(bottom: 15.0),
              child: Row(
                children: [
                  // Segundo Dropdown (Orden)
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.6, // 60% del ancho de la pantalla
                    child: CustomDropdownButton<int>(
                      labelText: 'Seleccione el Orden',
                      items: List.generate(10, (index) => index + 1),
                      selectedValue: selectedNumber2,
                      onChanged: (newValue) {
                        setState(() {
                          selectedNumber2 = newValue;
                        });
                      },
                      itemTextStyle: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'TitilliumWeb',
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(width: 0.5), // Espacio entre el dropdown y el botón

                  // Botón de asignación con CustomBottonSec
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.30, // Ancho reducido al 25% de la pantalla
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
