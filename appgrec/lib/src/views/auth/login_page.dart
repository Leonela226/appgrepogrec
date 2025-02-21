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

  void _login(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      String? error = await authProvider.loginWithEmail(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (error != null) {
        _showSnackBar(error);
      } else {
        Navigator.pushReplacementNamed(context, Routes.home);
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
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
                CustomTextFormField(
                  labelText: 'Correo Electrónico',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  controller: _emailController,
                  focusNode: _emailFocusNode,
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
                const SizedBox(height: 16),
                CustomTextFormField(
                  labelText: 'Contraseña',
                  icon: Icons.lock,
                  obscureText: true,
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tu contraseña.';
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).unfocus();
                  },
                ),
                const SizedBox(height: 24),
                CustomButton(
                  text: 'Iniciar Sesión',
                  onPressed: () => _login(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
