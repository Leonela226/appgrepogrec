import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  String? _userRole; // Para almacenar el id del rol del usuario

  AuthProvider() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  User? get user => _user;
  bool get isAuthenticated => _user != null;
  String? get userRole => _userRole; // Getter para el id_rol del usuario

  // Método para registrar al usuario con correo
  Future<String?> registerWithEmail(
    String email,
    String password,
    String name,
    String phone,
    String birthDate,
  ) async {
    try {
      // 1️⃣ Registrar el usuario en Firebase y obtener el firebase_uid
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = userCredential.user;
      String uid = _user!.uid;

      // 2️⃣ Enviar los datos al backend, incluyendo el firebase_uid
      var response = await http.post(
        Uri.parse('${dotenv.env['FRONTEND_URL']}/api/auth/register'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "firebase_uid": uid,
          "email_user": email,
          "name_user": name,
          "phone_number": phone,
          "date_birth": birthDate,
        }),
      );

      if (response.statusCode == 201) {
        return null; // Registro exitoso
      } else {
        // Si el registro en la base de datos falla, se elimina el usuario de Firebase
        await _user!.delete(); // Eliminar usuario de Firebase
        return "Error en el servidor: ${response.body}";
      }
    } on FirebaseAuthException catch (e) {
      return _getErrorMessage(e);
    } catch (e) {
      return 'Error desconocido: $e';
    }
  }

  // Método para obtener el id_rol del usuario desde el backend
  Future<void> fetchUserRole() async {
    if (_user != null) {
      try {
        var response = await http.get(
          Uri.parse('${dotenv.env['FRONTEND_URL']}/api/user/user_role?firebase_uid=${_user!.uid}'),
          headers: {"Content-Type": "application/json"},
        );

        if (response.statusCode == 200) {
          var data = jsonDecode(response.body);
          _userRole = data['id_rol'].toString();
          notifyListeners();
        } else {
          _userRole = null;
          notifyListeners();
          debugPrint("Error obteniendo rol: ${response.body}");
        }
      } catch (e) {
        debugPrint("Error en la conexión: $e");
        _userRole = null; // Es importante también manejar esta variable en caso de error.
        notifyListeners();
      }
    }
  }

  // Inicio de sesión
  Future<String?> loginWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = userCredential.user;
      await fetchUserRole();  // Obtener el rol después de iniciar sesión
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      return _getErrorMessage(e);
    } catch (e) {
      return 'Error desconocido: $e';
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    _user = null;
    _userRole = null; // Limpiar el rol al hacer logout
    notifyListeners();
  }

  void _onAuthStateChanged(User? firebaseUser) {
    _user = firebaseUser;
    if (_user != null) {
      fetchUserRole();  // Obtener el rol cuando el estado de autenticación cambie
    }
    notifyListeners();
  }

  // Recuperación de contraseña
  Future<String?> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null; // Éxito
    } on FirebaseAuthException catch (e) {
      return _getErrorMessage(e); // Manejo de errores
    } catch (e) {
      return 'Error desconocido: $e'; // Manejo de errores generales
    }
  }

  String _getErrorMessage(FirebaseAuthException e) {
    Map<String, String> errorMessages = {
      'invalid-email': 'El correo electrónico no es válido.',
      'too-many-requests':
          'Has realizado demasiados intentos. Inténtalo más tarde.',
      'network-request-failed':
          'Problema de conexión. Verifica tu conexión a Internet.',
      'invalid-credential': 'El correo o la contraseña son incorrectos.',
      'email-already-in-use':
          'Este correo electrónico ya está registrado. Por favor, utiliza otro correo.'
    };

    debugPrint('Firebase Error Code: ${e.code}');

    if (errorMessages.containsKey(e.code)) {
      return errorMessages[e.code]!; 
    } else {
      return 'Error desconocido: ${e.message ?? "Inténtalo de nuevo más tarde."}';
    }
  }
}
