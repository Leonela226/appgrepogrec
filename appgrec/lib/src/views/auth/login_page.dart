import 'package:appgrec/src/widgets/custom_appbar.dart';
import 'package:appgrec/src/widgets/custom_button.dart';
import 'package:appgrec/src/widgets/custom_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:appgrec/src/providers/auth.dart';
import 'package:appgrec/src/routes/routes.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  // Función para manejar el inicio de sesión
  void _login(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      String? error = await authProvider.loginWithEmail(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (error != null) {
        // Si hay un error, mostrar un mensaje
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
      } else {
        // Si el login es exitoso, redirigir a la pantalla de inicio
        Navigator.pushReplacementNamed(context, Routes.home);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Campo para el correo electrónico
                CustomTextFormField(
                  labelText: 'Correo Electrónico',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  controller: _emailController,
                  focusNode: _emailFocusNode, // Asignar FocusNode
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tu correo electrónico.';
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_passwordFocusNode);
                  },
                ),
                SizedBox(height: 16),
                // Campo para la contraseña
                CustomTextFormField(
                  labelText: 'Contraseña',
                  icon: Icons.lock,
                  obscureText: true,
                  controller: _passwordController,
                  focusNode: _passwordFocusNode, // Asignar FocusNode
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tu contraseña.';
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).unfocus();    // Cierra el teclado cuando se termina el formulario
                  },
                ),
                SizedBox(height: 24),
                // Botón de inicio de sesión
                CustomButton(
                  text: 'Iniciar Sesión',
                  onPressed: () => _login(context), // Llamar la función _login al presionar
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
