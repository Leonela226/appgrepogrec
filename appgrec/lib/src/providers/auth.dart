import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  AuthProvider() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  User? get user => _user;
  bool get isAuthenticated => _user != null;

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
      Uri.parse('${dotenv.env['FRONTEND_URL']}/api/register'),
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
      // En caso de error en el backend, se puede eliminar el usuario de Firebase para evitar inconsistencias
      await _user!.delete();
      return "Error en el servidor: ${response.body}";
    }
  } on FirebaseAuthException catch (e) {
    return _getErrorMessage(e);
  } catch (e) {
    return 'Error desconocido: $e';
  }
}

// inicio de sesión 
  Future<String?> loginWithEmail(String email, String password) async {
    try {
      UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = userCredential.user;
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
    notifyListeners();
  }

  void _onAuthStateChanged(User? firebaseUser) {
    _user = firebaseUser;
    notifyListeners();
  }

// recuperación de contraseña
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
    };

    debugPrint('Firebase Error Code: ${e.code}');

    if (errorMessages.containsKey(e.code)) {
      return errorMessages[e.code]!;
    } else {
      return 'Error desconocido: ${e.message ?? "Inténtalo de nuevo más tarde."}';
    }
  }
}
