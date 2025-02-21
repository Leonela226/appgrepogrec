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
    String phoneNumber,
    String dateBirth,
  ) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      _user = userCredential.user;
      String uid = _user!.uid;

      int defaultRoleId = 3;

      var response = await http.post(
        Uri.parse('${dotenv.env['FRONTEND_URL']}/api/register'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "firebase_uid": uid,
          "name": name,
          "email": email,
          "phone_number": phoneNumber,
          "date_birth": dateBirth,
          "status": "activo",
          "id_role": defaultRoleId,
        }),
      );

      if (response.statusCode == 201) {
        return null;
      } else {
        return "Error en el servidor: ${response.body}";
      }
    } on FirebaseAuthException catch (e) {
      return _getErrorMessage(e);
    } catch (e) {
      return 'Error desconocido: $e';
    }
  }

  Future<String?> loginWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
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

String _getErrorMessage(FirebaseAuthException e) {
  // Mapa con mensajes personalizados
  Map<String, String> errorMessages = {
    'invalid-email': 'El correo electrónico no es válido.',
    'too-many-requests': 'Has realizado demasiados intentos. Inténtalo más tarde.',
    'network-request-failed': 'Problema de conexión. Verifica tu conexión a Internet.',
    'invalid-credential': 'El correo o la contraseña son incorrectos.',
  };

  // Depuración: imprimir el código del error
  debugPrint('Firebase Error Code: ${e.code}');

  // Retornar mensaje personalizado si existe en el mapa
  if (errorMessages.containsKey(e.code)) {
    return errorMessages[e.code]!;
  } else {
    // Si no se encuentra el código, mostrar el mensaje real del error
    return 'Error desconocido: ${e.message ?? "Inténtalo de nuevo más tarde."}';
  }
}


}
