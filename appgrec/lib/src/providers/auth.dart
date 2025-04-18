import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  String? _userRole;

  AuthProvider() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  User? get user => _user;
  bool get isAuthenticated => _user != null;
  String? get userRole => _userRole;

  // ✅ Obtener id_user almacenado
  Future<int?> getUserIdFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('id_user');
  }

  // ✅ Registrar usuario
  Future<String?> registerWithEmail(
    String email,
    String password,
    String name,
    String phone,
    String birthDate,
  ) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = userCredential.user;
      String uid = _user?.uid ?? '';

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
        return null;
      } else {
        if (_user != null) {
          await _user!.delete();
        }
        return "Error en el servidor: ${response.body}";
      }
    } on FirebaseAuthException catch (e) {
      return _getErrorMessage(e);
    } catch (e) {
      return 'Error desconocido: $e';
    }
  }

  // ✅ Iniciar sesión y guardar id_user
  Future<String?> loginWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = userCredential.user;

      // 👉 Obtener id_user desde backend
      if (_user != null) {
        final response = await http.get(
          Uri.parse('${dotenv.env['FRONTEND_URL']}/api/auth/by-uid/${_user!.uid}'),
          headers: {"Content-Type": "application/json"},
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final idUser = data['id_user'];


          // 💾 Guardar id_user en SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt('id_user', idUser);

          await fetchUserRole(); // Obtener rol
          notifyListeners();
          return null;
        } else {
          return "Error al obtener la información del usuario: ${response.body}";
        }
      } else {
        return 'Error de usuario no encontrado';
      }
    } on FirebaseAuthException catch (e) {
      return _getErrorMessage(e);
    } catch (e) {
      return 'Error desconocido: $e';
    }
  }

  // ✅ Obtener rol
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
        } else {
          _userRole = null;
          debugPrint("Error obteniendo rol: ${response.body}");
        }
      } catch (e) {
        _userRole = null;
        debugPrint("Error en la conexión: $e");
      }
      notifyListeners();
    }
  }

  // ✅ Logout
  Future<void> logout() async {
    await _auth.signOut();
    _user = null;
    _userRole = null;

    // 🔥 Limpiar id_user de SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('id_user');

    notifyListeners();
  }

  // ✅ Detectar cambio de estado
  void _onAuthStateChanged(User? firebaseUser) {
    _user = firebaseUser;
    if (_user != null) {
      fetchUserRole();
    }
    notifyListeners();
  }

  // ✅ Recuperar contraseña
  Future<String?> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      return _getErrorMessage(e);
    } catch (e) {
      return 'Error desconocido: $e';
    }
  }

  // ✅ Mapear errores de Firebase
  String _getErrorMessage(FirebaseAuthException e) {
    Map<String, String> errorMessages = {
      'invalid-email': 'El correo electrónico no es válido.',
      'too-many-requests': 'Demasiados intentos. Intenta más tarde.',
      'network-request-failed': 'Verifica tu conexión a Internet.',
      'invalid-credential': 'Correo o contraseña incorrectos.',
      'email-already-in-use': 'Este correo ya está registrado.',
    };

    debugPrint('Firebase Error Code: ${e.code}');

    return errorMessages[e.code] ?? 'Error desconocido: ${e.message ?? "Inténtalo más tarde."}';
  }
}
