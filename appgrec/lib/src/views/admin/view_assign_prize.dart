import 'package:appgrec/src/utils/validators/assign_prize_validators.dart';
import 'package:appgrec/src/views/admin/view_giveaways.dart';
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
  List<Map<String, dynamic>> prizeNames = [];
  Map<String, dynamic>? selectedPrize;

  String? baseUrl;
  List<Map<String, dynamic>> assignedPrizes = [];
  bool prizesAssigned = false; 

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
    _fetchAssignedPrizes();
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
          prizeNames = List<Map<String, dynamic>>.from(data['data'].map((prize) => {
            'id_prize': prize['id_prize'], 
            'name_prize': prize['name_prize']
          }));
          assignedPrizes = []; 
        });
      } else {
        CustomSnackbar.showError(context, 'Error al cargar los premios');
      }
    } catch (error) {
      CustomSnackbar.showError(context, 'Error al obtener los premios: $error');
    }
  }

  Future<void> _onAssign() async {
    if (prizesAssigned) {
      CustomSnackbar.showWarning(context, 'Los datos ya se han guardado.');
      return;
    }

    if (selectedPrize != null) {
      try {
        final response = await http.get(Uri.parse('$baseUrl/api/assign/countPrizes/${widget.giveawayId}'));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          int assignedFromDb = data['assignedPrizesCount'];
          int maxPrizes = prizeCount ?? 0;
          int assignedLocally = assignedPrizes.length;
          
          if (hasReachedMaxPrizes(assignedFromDb, assignedLocally, maxPrizes)) {
            CustomSnackbar.showWarning(
              context,
              'No se pueden asignar más premios. Ya se alcanzó el límite de $maxPrizes.'
            );
            return;
          }

          final selectedPrizeId = selectedPrize?['id_prize'];

          final nextOrder = getNextAvailableOrder(assignedPrizes);

          setState(() {
            assignedPrizes.add({
              'premio': selectedPrize?['name_prize'],
              'orden': nextOrder,
              'premio_id': selectedPrizeId,
            });
            selectedPrize = null;
            selectedNumber2 = null;
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

  Future<void> _onSave() async {
    if (assignedPrizes.isEmpty) {
      CustomSnackbar.showWarning(context, 'No hay premios asignados.');
      return;
    }

    try {
      List<Map<String, dynamic>> prizesToSave = assignedPrizes.map((prize) {
        return {
          'prize_id': prize['premio_id'], 
          'rank': prize['orden'], 
        };
      }).toList();

      final response = await http.post(
        Uri.parse('$baseUrl/api/assign/save'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'id_giveaway': widget.giveawayId,
          'assignedPrizes': prizesToSave,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        CustomSnackbar.showSuccess(context, data['message']);
        setState(() {
          prizesAssigned = true; // Se actualiza el estado a que los premios han sido guardados
        });
      } else {
        final data = json.decode(response.body);
        CustomSnackbar.showError(context, data['message']);
      }
    } catch (error) {
      CustomSnackbar.showError(context, 'Error al guardar los premios asignados: $error');
    }
  }

  Future<void> _fetchAssignedPrizes() async {
  try {
    final response = await http.get(Uri.parse('$baseUrl/api/assign/assignPrize/${widget.giveawayId}'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      
      // Si los premios asignados están vacíos, mostramos el mensaje adecuado
      if (data['data'].isEmpty) {
        CustomSnackbar.showInfo(context, 'Todo listo para la asignación de premios');
      } else {
        setState(() {
          assignedPrizes = List<Map<String, dynamic>>.from(data['data'].map((prize) => {
            'premio': prize['name_prize'],
            'orden': prize['rank'],
          }));
        });
      }
    } else {
      CustomSnackbar.showError(context, 'Error al cargar los premios asignados');
    }
  } catch (error) {
    CustomSnackbar.showError(context, 'Error al obtener los premios asignados: $error');
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
          crossAxisAlignment: CrossAxisAlignment.start,
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
                width: MediaQuery.of(context).size.width * 0.9,
                child: CustomDropdownButton<Map<String, dynamic>>(
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
                  const SizedBox(width: 0.5),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: CustomBottonSec(
                      text: 'Asignar',
                      onPressed: _onAssign,
                      backgroundColor: const Color(0xFF434244),
                      paddingHorizontal: 12.0,
                      paddingVertical: 6.0,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 5),
            CustomPaginatedTable(
              columns: [
                DataColumn(label: Text('Premios')),
                DataColumn(label: Text('Orden de Asignación')),
              ],
              dataSource: AssignedPrizesData(assignedPrizes),
              headerText: 'Detalles de asignación',
            ),

            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.30,
                  child: CustomBottonSec(
                    text: 'Guardar',
                    onPressed: _onSave,
                    paddingHorizontal: 12.0,
                    paddingVertical: 6.0,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.30,
                  child: CustomBottonSec(
                    text: 'Volver',
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const ViewGiveawaysScreen()),
                      );
                    },
                    paddingHorizontal: 12.0,
                    paddingVertical: 6.0,
                  ),
                ),
              ],
            ) 
          ],
        ),
      ),
    );
  }
}

class AssignedPrizesData extends DataTableSource {
  final List<Map<String, dynamic>> _data;

  AssignedPrizesData(this._data);

  @override
  DataRow getRow(int index) {
    assert(index >= 0 && index < _data.length);
    final row = _data[index];
    return DataRow(cells: [
      DataCell(Align(
        child: Text(
          row['premio'] ?? '',
          textAlign: TextAlign.left,
          style: TextStyle(
            fontFamily: 'TitilliumWeb',
            fontWeight: FontWeight.w300,
            fontSize: 12,
          ),
        ),
      )),
      DataCell(Align(
        child: Text(
          row['orden'] != null ? row['orden'].toString() : '0',
          textAlign: TextAlign.left,
          style: TextStyle(
            fontFamily: 'TitilliumWeb',
            fontWeight: FontWeight.normal,
            fontSize: 13,
          ),
        ),
      )),
    ]);
  }

  @override
  int get rowCount => _data.length;

  @override
  int get selectedRowCount => 0;

  @override
  bool get isRowCountApproximate => false;
}
