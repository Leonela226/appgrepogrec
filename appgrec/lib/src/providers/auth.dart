import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  AuthProvider() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  User? get user => _user;
  bool get isAuthenticated => _user != null;

  // Registro de usuario
  Future<String?> registerWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = userCredential.user;
      notifyListeners();
      return null; // Registro exitoso
    } on FirebaseAuthException catch (e) {
      return _getErrorMessage(e); // Devolver un mensaje de error personalizado
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
      notifyListeners();
      return null; // Inicio de sesión exitoso
    } on FirebaseAuthException catch (e) {
      return _getErrorMessage(e); // Devolver un mensaje de error personalizado
    }
  }

  // Cerrar sesión
  Future<void> logout() async {
    await _auth.signOut();
    _user = null;
    notifyListeners();
  }

  // Manejar cambios en el estado de autenticación
  void _onAuthStateChanged(User? firebaseUser) {
    _user = firebaseUser;
    notifyListeners();
  }

  // Obtener el mensaje de error personalizado
  String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'wrong-password':
        return 'El correo o la contraseña son incorrectos. Verifica tus credenciales.';
      case 'invalid-email':
        return 'El correo electrónico no es válido. Ingresa una dirección de correo válida.';
      case 'too-many-requests':
        return 'Has realizado demasiados intentos. Intenta nuevamente más tarde.';
      case 'network-request-failed':
        return 'Problema de conexión. Verifica tu conexión a Internet.';
      default:
        return e.message ?? 'Error desconocido. Intenta nuevamente más tarde.';
    }
  }
}
