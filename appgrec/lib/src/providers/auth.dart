import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// Define la clase `AuthProvider`, que extiende `ChangeNotifier` para manejar la autenticación con Firebase.
class AuthProvider with ChangeNotifier {
  /// Crea una instancia de `FirebaseAuth` para gestionar la autenticación.
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Almacena la información del usuario autenticado.
  User? _user;

  /// Constructor de la clase `AuthProvider`.
  /// Escucha los cambios en el estado de autenticación y actualiza la variable `_user` en consecuencia.
  AuthProvider() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  /// Obtiene el usuario autenticado actualmente.
  User? get user => _user;

  /// Verifica si el usuario está autenticado.
  bool get isAuthenticated => _user != null;

  /// Registra un nuevo usuario con correo y contraseña en Firebase.
  /// Retorna `null` si el registro es exitoso o un mensaje de error en caso contrario.
  Future<String?> registerWithEmail(String email, String password) async {
    try {
      /// Crea un nuevo usuario con el correo y contraseña proporcionados.
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      /// Asigna el usuario autenticado a la variable `_user`.
      _user = userCredential.user;

      /// Notifica a los oyentes que hubo un cambio en el estado de autenticación.
      notifyListeners();
      return null; // Indica que el registro fue exitoso.
    } on FirebaseAuthException catch (e) {
      /// Retorna el mensaje de error en caso de fallo en el registro.
      return e.message;
    }
  }

  /// Inicia sesión con un usuario existente mediante correo y contraseña.
  /// Retorna `null` si el inicio de sesión es exitoso o un mensaje de error en caso contrario.
  Future<String?> loginWithEmail(String email, String password) async {
    try {
      /// Autentica al usuario con Firebase utilizando el correo y la contraseña.
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      /// Asigna el usuario autenticado a la variable `_user`.
      _user = userCredential.user;

      /// Notifica a los oyentes sobre el cambio en el estado de autenticación.
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      /// Retorna el mensaje de error en caso de fallo en el inicio de sesión.
      return e.message;
    }
  }

  /// Cierra la sesión del usuario autenticado.
  Future<void> logout() async {
    /// Cierra la sesión con Firebase.
    await _auth.signOut();

    /// Establece la variable `_user` como `null` para indicar que no hay usuario autenticado.
    _user = null;

    /// Notifica a los oyentes sobre el cambio en el estado de autenticación.
    notifyListeners();
  }

  /// Método privado que se ejecuta cuando hay un cambio en el estado de autenticación.
  /// Actualiza la variable `_user` con la información del usuario autenticado.
  void _onAuthStateChanged(User? firebaseUser) {
    _user = firebaseUser;

    /// Notifica a los oyentes sobre el cambio en el estado de autenticación.
    notifyListeners();
  }
}
