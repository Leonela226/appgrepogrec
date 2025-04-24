import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:appgrec/src/widgets/custom_bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:appgrec/src/widgets/custom_appbar.dart';
import 'package:appgrec/src/widgets/custom_text_form_field.dart';
import 'package:appgrec/src/widgets/custom_snackbar.dart';

class ParticipationHistoryScreen extends StatefulWidget {
  const ParticipationHistoryScreen({super.key});

  @override
  State<ParticipationHistoryScreen> createState() => _ParticipationHistoryScreenState();
}

class _ParticipationHistoryScreenState extends State<ParticipationHistoryScreen> {
  late String baseUrl;
  bool isLoading = true;
  int currentPage = 1;
  final int itemsPerPage = 5;
  List<Map<String, dynamic>> participations = [];
  List<Map<String, dynamic>> filteredParticipations = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    baseUrl = dotenv.env['FRONTEND_URL'] ?? '';
    if (baseUrl.isEmpty) {
      CustomSnackbar.showError(context, 'Error: FRONTEND_URL no está definida.');
      return;
    }
    _loadParticipationHistory();
  }

  Future<void> _loadParticipationHistory() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final firebaseUid = user?.uid;

      if (firebaseUid == null) {
        CustomSnackbar.showError(context, 'Usuario no autenticado.');
        setState(() => isLoading = false);
        return;
      }

      final url = '$baseUrl/api/participation/participationSummary';
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'firebase_uid': firebaseUid}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final list = List<Map<String, dynamic>>.from(data['data']);
        setState(() {
          participations = list;
          filteredParticipations = list;
          isLoading = false;
        });
      } else {
        throw Exception('Error al cargar el historial de participaciones');
      }
    } catch (e) {
      if (mounted) {
        CustomSnackbar.showError(context, 'Error: $e');
        setState(() => isLoading = false);
      }
    }
  }

  void _filterParticipations(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredParticipations = List.from(participations);
      } else {
        filteredParticipations = participations
            .where((item) => item['giveaway_name']
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList();
      }
      currentPage = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    int totalPages = (filteredParticipations.length / itemsPerPage).ceil();
    int startIndex = (currentPage - 1) * itemsPerPage;
    int endIndex =
        (startIndex + itemsPerPage).clamp(0, filteredParticipations.length);
    List<Map<String, dynamic>> visibleItems =
        filteredParticipations.sublist(startIndex, endIndex);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: const CustomAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                SizedBox(width: 8),
                Text(
                  'Historial de Participaciones',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'TitilliumWeb',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            CustomTextFormField(
              labelText: 'Buscar por nombre de sorteo',
              icon: Icons.search,
              controller: _searchController,
              onChanged: _filterParticipations,
            ),
            const SizedBox(height: 10),
            isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF0000)),
                    ),
                  )
                : filteredParticipations.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Text(
                          'No hay participaciones registradas',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      )
                    : Expanded(
                        child: ListView.builder(
                          itemCount: visibleItems.length,
                          itemBuilder: (context, index) {
                            final item = visibleItems[index];
                            return Card(
                              color: const Color(0xFFF8F8F8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                leading: const Icon(Icons.card_giftcard, color: Colors.redAccent),
                                title: Text(
                                  item['giveaway_name'],
                                  style: const TextStyle(
                                    fontFamily: 'TitilliumWeb',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Primera participación: ${item['first_participation_date']}'),
                                    Text('Total de participaciones: ${item['total_participations']}'),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed:
                      currentPage > 1 ? () => setState(() => currentPage--) : null,
                ),
                Text('Página $currentPage de $totalPages'),
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: currentPage < totalPages
                      ? () => setState(() => currentPage++)
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }
}