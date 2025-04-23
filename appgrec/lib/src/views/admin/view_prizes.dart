import 'dart:convert';
import 'package:appgrec/src/views/admin/prize_form_bottom_sheet.dart';
import 'package:appgrec/src/widgets/custom_buttons_sec.dart';
import 'package:appgrec/src/widgets/custom_drawer.dart';
import 'package:flutter/material.dart';
import 'package:appgrec/src/widgets/custom_appbar.dart';
import 'package:appgrec/src/widgets/custom_text_form_field.dart';
import 'package:appgrec/src/widgets/custom_snackbar.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ViewPrizesScreen extends StatefulWidget {
  const ViewPrizesScreen({super.key});

  @override
  ViewPrizesScreenState createState() => ViewPrizesScreenState();
}

class ViewPrizesScreenState extends State<ViewPrizesScreen> {
  final int itemsPerPage = 5;
  int currentPage = 1;
  List<String> prizes = [];
  List<String> filteredPrizes = [];
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  void addPrize(String name) {
    setState(() {
      prizes.add(name);
      filteredPrizes.add(name);
    });
  }

  @override
  void initState() {
    super.initState();
    _loadPrizes();
  }

  Future<void> _loadPrizes() async {
    final String? baseUrl = dotenv.env['FRONTEND_URL'];
    if (baseUrl == null || baseUrl.isEmpty) {
      if (mounted) {
        CustomSnackbar.showError(context, 'Error: BACKEND_URL no está definida.');
      }
      return;
    }

    try {
      final response = await http.get(Uri.parse('$baseUrl/api/prizes/all'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          if (data['data'] is List) {
            setState(() {
              prizes = List<String>.from(data['data']);
              filteredPrizes = List.from(prizes);
              isLoading = false;
            });
          } else {
            CustomSnackbar.showError(context, 'Error: los datos de los premios no son válidos.');
            setState(() {
              isLoading = false;
            });
          }
        }
      } else {
        throw Exception('Error al cargar los premios');
      }
    } catch (e) {
      if (mounted) {
        CustomSnackbar.showError(context, 'Error al cargar los premios: $e');
        setState(() {
          isLoading = false;
        });
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

  @override
  Widget build(BuildContext context) {
    int totalPages = (filteredPrizes.length / itemsPerPage).ceil().clamp(1, double.infinity).toInt();
    int startIndex = (currentPage - 1) * itemsPerPage;
    int endIndex = (startIndex + itemsPerPage).clamp(0, filteredPrizes.length);
    List<String> visiblePrizes = filteredPrizes.sublist(startIndex, endIndex);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        drawer: const CustomDrawer(),
        appBar: const CustomAppBar(),
        body: SingleChildScrollView( // Utilizamos SingleChildScrollView para que el contenido sea desplazable
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
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
                // Este contenedor con el ListView
                isLoading
                    ? const Center(child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF0000)), // Usando el color rojo
                    ))
                    : filteredPrizes.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Text(
                                'Aún no hay premios creados',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey, fontFamily: 'TitilliumWeb'),
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true, // No se expandirá a toda la altura
                            itemCount: visiblePrizes.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text(
                                  visiblePrizes[index],
                                  style: const TextStyle(fontFamily: 'TitilliumWeb'),
                                ),
                                leading: const Icon(Icons.card_giftcard),
                                tileColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                              );
                            },
                          ),
                const SizedBox(height: 20),
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
                        style: const TextStyle(fontFamily: 'TitilliumWeb', fontWeight: FontWeight.w400),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward),
                        onPressed: currentPage < totalPages ? () => setState(() => currentPage++) : null,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: CustomBottonSec(
                    text: 'Agregar',
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return PrizeFormBottomSheet(
                            onSave: (name, description) {
                              addPrize(name);
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
