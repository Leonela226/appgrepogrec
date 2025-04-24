import 'package:appgrec/src/models/user_model.dart';
import 'package:appgrec/src/widgets/custom_appbar.dart';
import 'package:appgrec/src/widgets/custom_bottom_nav_bar.dart';
import 'package:appgrec/src/widgets/custom_drawer.dart';
import 'package:appgrec/src/widgets/custom_snackbar.dart';
import 'package:appgrec/src/widgets/custom_user_profile_content.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfileClientScreen extends StatefulWidget {
  const ProfileClientScreen({super.key});

@override
  ProfileAdminScreenState createState() => ProfileAdminScreenState();

}

class ProfileAdminScreenState extends State<ProfileClientScreen> {
  late UserModel user;
  String? baseUrl;
  bool isLoading = true;

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
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      final firebaseUid = firebaseUser?.uid;

      if (firebaseUid == null) {
        throw Exception('No se pudo obtener el UID del usuario');
      }
      
      final response = await http.get(Uri.parse('$baseUrl/api/profileUsers/firebase/$firebaseUid'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          user = UserModel.fromJson(data);

          isLoading = false;
        });
      } else {
        throw Exception('Error al cargar los datos del usuario');
      }
    } catch (e) {
      if (mounted) {
        CustomSnackbar.showError(context, 'No se pudo cargar el perfil.');
      }
    }
  }

  void _saveUser(UserModel updatedUser) async {
    final url = Uri.parse('$baseUrl/api/users/${updatedUser.id}');
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name_user': updatedUser.name,
          'email_user': updatedUser.email,
          'phone_number': updatedUser.phone,
          'date_birth': updatedUser.birthDate,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          user = updatedUser;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil actualizado exitosamente')),
        );
      } else {
        throw Exception('Error al actualizar el perfil');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al actualizar el perfil')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        drawer: const CustomDrawer(),
        appBar: const CustomAppBar(),
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF0000)), // Usando el color rojo
          )),
      );
    }

    return Scaffold(
      appBar: const CustomAppBar(
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: UserProfileForm(
          user: user,
          onSave: _saveUser,
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }
}
