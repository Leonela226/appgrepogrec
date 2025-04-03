import 'dart:convert';
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

  Future<void> _loadGiveaways() async {
    final String? baseUrl = dotenv.env['FRONTEND_URL'];
    if (baseUrl == null || baseUrl.isEmpty) {
      if (mounted) {
        CustomSnackbar.showError(context, 'Error: BACKEND_URL no está definida.');
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

  void _createGiveaway() {
    // Aquí puedes agregar la lógica para crear un premio
    CustomSnackbar.showSuccess(context, 'Función para agregar premio en desarrollo.');
  }

  @override
  Widget build(BuildContext context) {
    int totalPages = (filteredGiveaways.length / itemsPerPage).ceil().clamp(1, double.infinity).toInt();
    int startIndex = (currentPage - 1) * itemsPerPage;
    int endIndex = (startIndex + itemsPerPage).clamp(0, filteredGiveaways.length);
    List<Map<String, dynamic>> visibleGiveaways = filteredGiveaways.sublist(startIndex, endIndex);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        drawer: const CustomDrawer(),
        appBar: const CustomAppBar(),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Gestión de Sorteos',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'TitilliumWeb',
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
                    ? const Center(child: CircularProgressIndicator())
                    : filteredGiveaways.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Text(
                                'Aún no hay sorteos creados',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: visibleGiveaways.length,
                            itemBuilder: (context, index) {
                              final giveaway = visibleGiveaways[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 10),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(10),
                                  leading: const Icon(Icons.card_giftcard),
                                  title: Text(
                                    giveaway['name'],
                                    style: const TextStyle(fontFamily: 'TitilliumWeb'),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Fecha inicio: ${giveaway['start_date']}'),
                                      Text('Fecha fin: ${giveaway['end_date']}'),
                                      Text('Fecha sorteo: ${giveaway['draw_date']}'),
                                      Text('Estado: ${giveaway['status']}'),
                                    ],
                                  ),
                                ),
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
                const SizedBox(height: 20),
                // Aquí está el botón al final
                CustomBottonSec(
                  text: 'Agregar',
                  onPressed: _createGiveaway,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
