import 'package:appgrec/src/widgets/custom_appbar.dart';
import 'package:appgrec/src/widgets/custom_drawer.dart';
import 'package:appgrec/src/widgets/custom_dropdownbottom.dart';
import 'package:appgrec/src/widgets/custom_snackbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:appgrec/src/widgets/custom_text_form_field.dart';

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }
}

class UserModel {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String birthDate;
  final String role;
  String status;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.birthDate,
    required this.role,
    required this.status,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      birthDate: json['birthDate'],
      role: json['role'],
      status: (json['status'] as String).capitalize(),
    );
  }
}

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  UserManagementScreenState createState() => UserManagementScreenState();
}

class UserManagementScreenState extends State<UserManagementScreen> {
  List<UserModel> allUsers = [];
  List<UserModel> filteredUsers = [];
  TextEditingController searchController = TextEditingController();
  String selectedStatus = 'Todos';
  String selectedRole = 'Todos'; // Nueva variable para el filtro por rol
  bool isLoading = true;
  String userRole = '';

  int currentPage = 1;
  final int usersPerPage = 10;
  late String baseUrl;

  @override
  void initState() {
    super.initState();
    baseUrl = dotenv.env['FRONTEND_URL'] ?? '';
    if (baseUrl.isEmpty) {
      CustomSnackbar.showError(context, 'Error: FRONTEND_URL no está definida.');
      return;
    }
    fetchUserRole();
    fetchUsers();
  }

  Future<void> fetchUserRole() async {
    try {
      final firebaseUser = FirebaseAuth.instance.currentUser;

      if (firebaseUser == null) {
        CustomSnackbar.showError(context, 'Usuario no autenticado.');
        return;
      }

      final firebaseUid = firebaseUser.uid;

      final response = await http.get(
        Uri.parse('$baseUrl/api/auth/by-uid/$firebaseUid'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          userRole = data['id_rol'].toString();
        });
      } else {
        CustomSnackbar.showError(context, 'Error al obtener el rol: ${response.statusCode}');
      }
    } catch (e) {
      CustomSnackbar.showError(context, 'Error al obtener el rol del usuario: $e');
    }
  }

  Future<void> fetchUsers() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/auth/all'));
      if (response.statusCode == 200) {
        final List jsonData = jsonDecode(response.body);
        allUsers = jsonData.map((e) => UserModel.fromJson(e)).toList();
        filteredUsers = allUsers;
      } else {
        print('Error al obtener usuarios: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }

    setState(() => isLoading = false);
  }

  void _filterUsers(String query) {
    setState(() {
      currentPage = 1;
      filteredUsers = allUsers.where((user) {
        final nameMatch = user.name.toLowerCase().contains(query.toLowerCase());
        final emailMatch = user.email.toLowerCase().contains(query.toLowerCase());
        final statusMatch = selectedStatus == 'Todos' || user.status == selectedStatus;
        final roleMatch = selectedRole == 'Todos' || user.role == selectedRole;
        return (nameMatch || emailMatch) && statusMatch && roleMatch;
      }).toList();
    });
  }

  Future<void> _updateUserStatus(int userId, String newStatus) async {
    final url = Uri.parse('$baseUrl/api/users/$userId/status');
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'status': newStatus}),
      );
      if (response.statusCode == 200) {
        setState(() {
          final user = allUsers.firstWhere((u) => u.id == userId);
          user.status = newStatus;
        });
      } else {
        print('Error al actualizar estado: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalUsers = filteredUsers.length;
    final totalPages = (totalUsers / usersPerPage).ceil();
    final startIndex = (currentPage - 1) * usersPerPage;
    final endIndex = (startIndex + usersPerPage).clamp(0, totalUsers);
    final usersToDisplay = filteredUsers.sublist(startIndex, endIndex);

    return Scaffold(
      drawer: const CustomDrawer(),
      appBar: const CustomAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              'Gestión de Usuarios',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                fontFamily: 'TitilliumWeb', // Fuente aplicada
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            CustomTextFormField(
              labelText: 'Buscar por nombre o correo',
              icon: Icons.search,
              controller: searchController,
              onChanged: _filterUsers,
            ),
            const SizedBox(height: 12),
             Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: [
                // Dropdown para el estado
            if (userRole != 'Cliente')
              SizedBox(
                width: 150,  // Reducir el tamaño del dropdown de estado
                height: 47,
              child: CustomDropdownButton<String>(
                labelText: 'Estado',
                items: ['Todos', 'Activo', 'Inactivo'],
                selectedValue: selectedStatus,
                onChanged: (newStatus) {
                  if (newStatus != null) {
                    setState(() {
                      selectedStatus = newStatus;
                      _filterUsers(searchController.text);
                    });
                  }
                },
              ),
            ),

             SizedBox(
              width: 175,  // Reducir el tamaño del dropdown de rol
              height: 47,
              child: CustomDropdownButton<String>(
                labelText: 'Rol',
                items: ['Todos', 'Administrador', 'Cliente'],
                selectedValue: selectedRole,
                onChanged: (newRole) {
                  if (newRole != null) {
                    setState(() {
                      selectedRole = newRole;
                      _filterUsers(searchController.text);
                    });
                  }
                },
              ),
            ),
          ],
        ),
            const SizedBox(height: 16),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF0000)), // Usando el color rojo
                  ))
                  : filteredUsers.isEmpty
                      ? const Center(
                          child: Text(
                            'No se encontraron usuarios',
                            style: TextStyle(
                               fontSize: 18,
                               fontWeight: FontWeight.bold,
                               color: Colors.grey,
                               fontFamily: 'TitilliumWeb', // Fuente aplicada
                              ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: usersToDisplay.length,
                          itemBuilder: (context, index) {
                            final user = usersToDisplay[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                                  title: Text(
                                    user.name,
                                      style: const TextStyle(
                                        fontFamily: 'TitilliumWeb',
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16 // Fuente aplicada
                                      ),
                                    ),
                                    subtitle:DefaultTextStyle(
                                      style: const TextStyle(
                                        fontFamily: 'TitilliumWeb',
                                        fontWeight: FontWeight.w300,
                                        fontSize: 14, // Tamaño común
                                        color: Colors.black, // Color común
                                      ),
                                      child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Correo: ${user.email}'),
                                      Text('Teléfono: ${user.phone}'),
                                      Text('Nacimiento: ${user.birthDate}'),
                                      Text('Rol: ${user.role}'),
                                      Text('Estado: ${user.status}'),
                                    ],
                                  ),
                                ),
                                  trailing: user.role != 'Cliente'
                                      ? 
                                      SizedBox(
                                          width: 135,  // Ajustar el ancho
                                          height: 47,  // Ajustar la altura
                                          child: CustomDropdownButton<String>(
                                            labelText: '',
                                            items: ['Activo', 'Inactivo'],
                                            selectedValue: user.status,
                                            onChanged: (newValue) {
                                              if (newValue != null) {
                                                _updateUserStatus(user.id, newValue);
                                              }
                                            },
                                            borderColor: const Color(0xFF434244),
                                          ),
                                        )
                                      : null,
                                ),
                              ),
                            );
                          },
                        ),
            ),
            const SizedBox(height: 10),
            if (!isLoading)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: currentPage > 1
                        ? () {
                            setState(() => currentPage--);
                          }
                        : null,
                  ),
                  Text(
                    'Página $currentPage de $totalPages',
                    style: const TextStyle(
                      fontFamily: 'TitilliumWeb', // Fuente aplicada
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: currentPage < totalPages
                        ? () {
                            setState(() => currentPage++);
                          }
                        : null,
                  ),
                ],
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Acción para agregar nuevo usuario
        },
        backgroundColor: const Color(0xFF434244),
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
    );
  }
}
