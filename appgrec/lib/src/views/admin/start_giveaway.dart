import 'dart:convert';
import 'package:appgrec/src/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:appgrec/src/widgets/custom_appbar.dart';
import 'package:appgrec/src/widgets/custom_drawer.dart';
import 'package:appgrec/src/widgets/custom_snackbar.dart';
import 'package:appgrec/src/widgets/custom_text_form_field.dart';

class StartGiveawayScreen extends StatefulWidget {
  const StartGiveawayScreen({super.key});

  @override
  State<StartGiveawayScreen> createState() => _StartGiveawayScreenState();
}

class _StartGiveawayScreenState extends State<StartGiveawayScreen> {
  final int itemsPerPage = 5;
  int currentPage = 1;

  List<Map<String, dynamic>> allGiveaways = [];
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
        CustomSnackbar.showError(context, 'Error: FRONTEND_URL no está definida.');
      }
      return;
    }

    try {
      final response = await http.get(Uri.parse('$baseUrl/api/participationPrize/getGivAvailable'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (mounted && data is List) {
          final giveaways = List<Map<String, dynamic>>.from(data);

          setState(() {
            allGiveaways = giveaways;
            filteredGiveaways = List.from(giveaways);
            isLoading = false;
          });
        }
      } else {
        throw Exception('Error al cargar los sorteos');
      }
    } catch (e) {
      if (mounted) {
        CustomSnackbar.showError(context, 'Error al cargar los sorteos: $e');
        setState(() => isLoading = false);
      }
    }
  }

  void _filterGiveaways(String query) {
    List<Map<String, dynamic>> results = allGiveaways.where((giveaway) {
      final name = giveaway['name']?.toString().toLowerCase() ?? '';
      return name.contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredGiveaways = results;
      currentPage = 1;
    });
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
        body: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Text(
                'Realización de Sorteos',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'TitilliumWeb',
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              // Fila con solo Buscador
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: CustomTextFormField(
                  labelText: 'Buscar sorteo',
                  icon: Icons.search,
                  controller: _searchController,
                  onChanged: _filterGiveaways,
                ),
              ),
              const SizedBox(height: 10), 
              // Lista
              isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF0000)),
                      ),
                    )
                  : filteredGiveaways.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Text(
                            'No hay sorteos con fechas disponibles',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey, fontFamily: 'TitilliumWeb'),
                          ),
                        )
                      : Expanded(
                          child: ListView.builder(
                            itemCount: visibleGiveaways.length,
                            itemBuilder: (context, index) {
                              final giveaway = visibleGiveaways[index];
                              final date = giveaway['drawDate'] ?? ''; 
                              final name = giveaway['name'] ?? 'Sin nombre';
                              final participations = giveaway['totalParticipations']?.toString() ?? '0';  
                              final prizes = giveaway['prizes'] ?? [];  
                                       
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 10),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                                  title: Text(
                                    name,
                                    style: const TextStyle(
                                      fontFamily: 'TitilliumWeb',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  subtitle: DefaultTextStyle(
                                    style: const TextStyle(
                                      fontFamily: 'TitilliumWeb',
                                      fontWeight: FontWeight.w300,
                                      fontSize: 14,
                                      color: Colors.black,
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Fecha Sorteo: $date'),
                                        Text('Participaciones: $participations'),
                                        Text('Premios: ${prizes.join(', ')}'),  
                                      ],
                                    ),
                                  ),
                                  trailing: SizedBox(
                                    width: 100,
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: ElevatedButton(
                                        onPressed: () {
                                            final codeGiveaway = giveaway['codeGiveaway'];  
                                           Navigator.pushNamed(context, Routes.rouletteScreen,  arguments: codeGiveaway);  
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color(0xFF434244),
                                          textStyle: const TextStyle(
                                            fontFamily: 'TitilliumWeb',
                                            fontWeight: FontWeight.w400,
                                            fontSize: 14,
                                          ),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(horizontal: 18),
                                        ),
                                        child: const Text(
                                          'Sortear',
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
              const SizedBox(height: 8),
              // Paginación
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
                      style: const TextStyle(fontFamily: 'TitilliumWeb'),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward),
                      onPressed: currentPage < totalPages ? () => setState(() => currentPage++) : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
