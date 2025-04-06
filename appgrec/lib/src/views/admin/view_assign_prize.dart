import 'package:flutter_dotenv/flutter_dotenv.dart';  // Asegúrate de importar dotenv
import 'package:appgrec/src/widgets/custom_appbar.dart';
import 'package:appgrec/src/widgets/custom_drawer.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:appgrec/src/widgets/custom_snackbar.dart';  // Asegúrate de importar CustomSnackbar

class AssignPrizeScreen extends StatefulWidget {
  final int giveawayId; // Definir el campo para almacenar el id del sorteo

  const AssignPrizeScreen({super.key, required this.giveawayId});  // Asegúrate de que sea requerido

  @override
  AssignPrizeScreenState createState() => AssignPrizeScreenState();
}

class AssignPrizeScreenState extends State<AssignPrizeScreen> {
  int? selectedNumber = 1; // Valor predeterminado para el primer dropdown
  int? selectedNumber2 = 1; // Valor predeterminado para el segundo dropdown
  String giveawayName = ''; // Variable para almacenar el nombre del sorteo

  @override
  void initState() {
    super.initState();
    _fetchGiveawayDetails(); // Llamada para obtener el nombre del sorteo
  }

  // Función para obtener los detalles del sorteo desde el backend
  Future<void> _fetchGiveawayDetails() async {
    final String? baseUrl = dotenv.env['FRONTEND_URL']; // Obtiene la URL del backend desde .env
    if (baseUrl == null || baseUrl.isEmpty) {
      if (mounted) {
        CustomSnackbar.showError(context, 'Error: FRONTEND_URL no está definida.');
      }
      return;
    }

    try {
      final response = await http.get(Uri.parse('$baseUrl/api/assign/giveaway/${widget.giveawayId}'));  // Usa la base URL de .env
      //print('Respuesta: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          giveawayName = data['name'];  // Suponiendo que el backend devuelve el nombre del sorteo en el campo 'name'
        });
      } else {
        // Mostrar mensaje de error con CustomSnackbar si la respuesta no es 200
        CustomSnackbar.showError(context, 'Error al cargar el sorteo');
      }
    } catch (error) {
      // Manejo de error y mostrar mensaje con CustomSnackbar
      CustomSnackbar.showError(context, 'Error al obtener los detalles del sorteo: $error');
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
              'Asignar Premios', // Título
              style: TextStyle(
                fontSize: 22, // Tamaño de fuente
                fontWeight: FontWeight.w600, // Peso de fuente
                fontFamily: 'TitilliumWeb', // Fuente personalizada
                color: Colors.black, // Color de texto
              ),
            ),
            const SizedBox(height: 20), // Espacio entre el título y el contenido

            // Aquí mostramos el nombre del sorteo o el texto "Cargando..."
            giveawayName.isNotEmpty
                ? Text(
                    'Sorteo: $giveawayName',
                    style: const TextStyle(
                      fontFamily: 'TitilliumWeb',
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                : const Text( // Mostramos "Cargando..." en lugar del CircularProgressIndicator
                    'Cargando...',
                    style: TextStyle(
                      fontFamily: 'TitilliumWeb',
                      fontSize: 16,
                      fontWeight: FontWeight.w300,
                    ),
                  ),

            const SizedBox(height: 30), // Espacio antes de los Dropdowns
            // Row con dos Dropdowns
            Row(
              mainAxisAlignment: MainAxisAlignment.center, // Centra los Dropdowns
              children: [
                // Primer Dropdown
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      const Text(
                        'Selecciona el Premio', // Texto encima del primer dropdown
                        style: TextStyle(
                          fontSize: 14, // Tamaño de fuente para el texto del dropdown
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8), // Espacio entre el texto y el dropdown
                      DropdownButton<int>(
                        value: selectedNumber,
                        items: List.generate(10, (index) {
                          int number = index + 1;
                          return DropdownMenuItem<int>(
                            value: number,
                            child: Text('$number'),
                          );
                        }),
                        onChanged: (newValue) {
                          setState(() {
                            selectedNumber = newValue;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20), // Espacio entre los dos dropdowns

                // Segundo Dropdown
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      const Text(
                        'Selecciona el orden', // Texto encima del segundo dropdown
                        style: TextStyle(
                          fontSize: 14, // Tamaño de fuente para el texto del dropdown
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8), // Espacio entre el texto y el dropdown
                      DropdownButton<int>(
                        value: selectedNumber2,
                        items: List.generate(10, (index) {
                          int number = index + 1;
                          return DropdownMenuItem<int>(
                            value: number,
                            child: Text('$number'),
                          );
                        }),
                        onChanged: (newValue) {
                          setState(() {
                            selectedNumber2 = newValue;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
