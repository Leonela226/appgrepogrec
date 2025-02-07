import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Registrar un usuario con email y contraseña
  Future<User?> registerWithEmail({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;
      await user?.sendEmailVerification(); // Enviar verificación por correo
      if (context.mounted) {
        _showSnackbar(context, "Registro exitoso. Verifica tu correo", SnackBarType.success);
      }
      return user;
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        _showSnackbar(context, e.message ?? "Error desconocido", SnackBarType.fail);
      }
      return null;
    }
  }

  /// Iniciar sesión con email y contraseña
  Future<User?> signInWithEmail({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;
      if (user != null && !user.emailVerified) {
        if (context.mounted) {
          _showSnackbar(context, "Por favor, verifica tu correo electrónico.", SnackBarType.alert);
        }
        return null;
      }
      if (context.mounted) {
        _showSnackbar(context, "Inicio de sesión exitoso", SnackBarType.success);
      }
      return user;
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        _showSnackbar(context, e.message ?? "Error desconocido", SnackBarType.fail);
      }
      return null;
    }
  }

  /// Cerrar sesión
  Future<void> signOut(BuildContext context) async {
    await _auth.signOut();
    if (context.mounted) {
      _showSnackbar(context, "Has cerrado sesión", SnackBarType.success);
    }
  }

  /// Restablecer la contraseña
  Future<void> resetPassword({
    required String email,
    required BuildContext context,
  }) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      if (context.mounted) {
        _showSnackbar(context, "Se ha enviado un enlace para restablecer la contraseña.", SnackBarType.success);
      }
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        _showSnackbar(context, e.message ?? "Error desconocido", SnackBarType.fail);
      }
    }
  }

  /// Mostrar mensajes con IconSnackBar
  void _showSnackbar(BuildContext context, String message, SnackBarType type) {
    if (context.mounted) {
      IconSnackBar.show(
        context,
        snackBarType: type,
        label: message,
      );
    }
  }
}
