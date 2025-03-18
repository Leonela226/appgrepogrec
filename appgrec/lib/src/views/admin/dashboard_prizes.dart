import 'dart:convert';  // Importa para decodificar la respuesta JSON
import 'dart:io';
import 'package:appgrec/src/views/admin/prize_form_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:appgrec/src/widgets/custom_buttons_sec.dart';
import 'package:appgrec/src/widgets/custom_appbar.dart';
import 'package:appgrec/src/widgets/custom_text_form_field.dart';
import 'package:appgrec/src/widgets/custom_snackbar.dart'; // Importa tu CustomSnackbar
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';  // Importa dotenv

class DashboardPrizesScreen extends StatefulWidget {
  const DashboardPrizesScreen({super.key});

  @override
  DashboardPrizesScreenState createState() => DashboardPrizesScreenState();
}

class DashboardPrizesScreenState extends State<DashboardPrizesScreen> {
  final int itemsPerPage = 5;
  int currentPage = 1;
  List<String> prizes = [];
  List<String> filteredPrizes = [];
  bool isEditing = false;
  String? selectedPrize;  // Premio seleccionado
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPrizes();
  }

  Future<void> _loadPrizes() async {
    final String? baseUrl = dotenv.env['FRONTEND_URL'];  // Cambia FRONTEND_URL por BACKEND_URL
    if (baseUrl == null || baseUrl.isEmpty) {
      if (mounted) {
        CustomSnackbar.showError(context, 'Error: BACKEND_URL no está definida.');
      }
      return;
    }

    try {
      final response = await http.get(Uri.parse('$baseUrl/api/prizes/all'));  // Asegúrate de que esta sea la URL correcta
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            prizes = List<String>.from(data['data'].map((item) => item['name']));  // Asumiendo que los premios tienen un campo 'name'
            filteredPrizes = List.from(prizes);
          });
        }
      } else {
        throw Exception('Error al cargar los premios');
      }
    } catch (e) {
      if (mounted) {
        CustomSnackbar.showError(context, 'Error al cargar los premios');
      }
    }
  }

  void _filterPrizes(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredPrizes = List.from(prizes);
      } else {
        filteredPrizes = prizes
            .where((prize) => prize.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
      currentPage = 1;
    });
  }

  void _handleSavePrize(String name, String description, File? image) {
    setState(() {
      prizes.add(name);
      filteredPrizes.add(name);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Premio "$name" agregado con éxito!')),
    );
  }

  void _handleEditPrize(String prize) {
    showModalBottomSheet(
      context: context,
      builder: (context) => PrizeFormBottomSheet(
        onSave: (name, description, image) {
          setState(() {
            prizes[prizes.indexOf(prize)] = name;
            filteredPrizes[filteredPrizes.indexOf(prize)] = name;
          });
          Navigator.pop(context);
          setState(() {
            selectedPrize = null;  // Deseleccionamos el premio al guardar
          });
        },
      ),
    ).whenComplete(() {
      setState(() {
        selectedPrize = null;  // Deseleccionamos el premio cuando se cierra el modal
      });
    });
  }

  void _handleDeletePrize(String prize) {
    setState(() {
      prizes.remove(prize);
      filteredPrizes.remove(prize);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Premio "$prize" eliminado con éxito!')),
    );
  }

  void _showTemporaryMessage() {
    // Usamos el CustomSnackbar para mostrar el mensaje de Info
    CustomSnackbar.showInfo(context, 'Seleccione el premio a editar');
  }

  @override
  Widget build(BuildContext context) {
    int totalPages = (filteredPrizes.length / itemsPerPage).ceil().clamp(1, double.infinity).toInt();
    int startIndex = (currentPage - 1) * itemsPerPage;
    int endIndex = (startIndex + itemsPerPage).clamp(0, filteredPrizes.length);
    List<String> visiblePrizes = filteredPrizes.sublist(startIndex, endIndex);

    return Scaffold(
      appBar: const CustomAppBar(),
      body: Column(
        children: [
          const SizedBox(height: 20),
          const Text(
            'Gestión de Premios',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              fontFamily: 'TitilliumWeb',
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 20),
          CustomTextFormField(
            labelText: 'Buscar premio',
            icon: Icons.search,
            controller: _searchController,
            onChanged: _filterPrizes,
          ),
          const SizedBox(height: 10),
          Expanded(
            child: isEditing
                ? ListView.builder(
                    itemCount: visiblePrizes.length,
                    itemBuilder: (context, index) {
                      bool isSelected = visiblePrizes[index] == selectedPrize;
                      return ListTile(
                        title: Text(
                          visiblePrizes[index],
                          style: TextStyle(
                            fontFamily: 'TitilliumWeb',
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        leading: const Icon(Icons.card_giftcard),
                        tileColor: isSelected
                            ? Color.fromRGBO(67, 66, 68, 0.2) // Menos oscuro con .fromRGBO
                            : Colors.white.withOpacity(0.9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                        onTap: () {
                          setState(() {
                            selectedPrize = visiblePrizes[index];  // Asignamos el premio seleccionado
                          });
                          _handleEditPrize(visiblePrizes[index]);
                          setState(() {
                            isEditing = false;
                          });
                        },
                      );
                    },
                  )
                : ListView.builder(
                    itemCount: visiblePrizes.length + 1,
                    itemBuilder: (context, index) {
                      if (index < visiblePrizes.length) {
                        bool isSelected = visiblePrizes[index] == selectedPrize;
                        return ListTile(
                          title: Text(
                            visiblePrizes[index],
                            style: TextStyle(
                              fontFamily: 'TitilliumWeb',
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          leading: const Icon(Icons.card_giftcard),
                          tileColor: isSelected
                              ? Color.fromRGBO(67, 66, 68, 0.2) // Menos oscuro con .fromRGBO
                              : Colors.white.withOpacity(0.9),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                        );
                      } else {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back),
                                onPressed: currentPage > 1
                                    ? () => setState(() => currentPage--)
                                    : null,
                              ),
                              Text(
                                'Página $currentPage de $totalPages',
                                style: TextStyle(
                                  fontFamily: 'TitilliumWeb',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.arrow_forward),
                                onPressed: currentPage < totalPages
                                    ? () => setState(() => currentPage++)
                                    : null,
                              ),
                            ],
                          ),
                        );
                      }
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: CustomBottonSec(
                    text: 'Agregar',
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => PrizeFormBottomSheet(
                          onSave: _handleSavePrize,
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: CustomBottonSec(
                    text: 'Editar',
                    onPressed: () {
                      setState(() {
                        isEditing = !isEditing;
                      });
                      _showTemporaryMessage(); // Usar el Snackbar de Info aquí
                    },
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: CustomBottonSec(
                    text: 'Eliminar',
                    onPressed: () {
                      if (visiblePrizes.isNotEmpty) {
                        _handleDeletePrize(visiblePrizes.first);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
