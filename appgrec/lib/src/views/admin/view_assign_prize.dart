import 'package:appgrec/src/widgets/custom_dropdownbottom.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:appgrec/src/widgets/custom_appbar.dart';
import 'package:appgrec/src/widgets/custom_drawer.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:appgrec/src/widgets/custom_snackbar.dart';

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
        });
      } else {
        CustomSnackbar.showError(context, 'Error al cargar los premios');
      }
    } catch (error) {
      CustomSnackbar.showError(context, 'Error al obtener los premios: $error');
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
          children: [
            const SizedBox(height: 20),
            const Text(
              'Asignación de Premios',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                fontFamily: 'TitilliumWeb',
                color: Colors.black,
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
                padding: const EdgeInsets.all(16.0),
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

            // Aquí colocamos ambos dropdowns uno debajo del otro
            Expanded(
              flex: 9, // Ocupa el 90% del espacio total
              child: Column(
                children: [
                  // Dropdown de premios
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0), // Espacio entre los dropdowns
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
                  // Dropdown de orden
                  CustomDropdownButton<int>(
                    labelText: 'Seleccione el Orden',
                    items: List.generate(10, (index) => index + 1),
                    selectedValue: selectedNumber2,
                    onChanged: (newValue) {
                      setState(() {
                        selectedNumber2 = newValue;
                      });
                    },
                    itemTextStyle: const TextStyle(
                      fontSize: 14,
                      fontFamily: 'TitilliumWeb',
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
