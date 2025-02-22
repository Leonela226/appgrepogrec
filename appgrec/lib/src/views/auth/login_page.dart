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
  
  bool _isPasswordObscure = true;
  bool _isLoading = false;

  void _login(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      String? error = await authProvider.loginWithEmail(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      setState(() {
        _isLoading = false;
      });

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
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Inicio de Sesión',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
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
                      obscureText: _isPasswordObscure,
                      controller: _passwordController,
                      focusNode: _passwordFocusNode,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa tu contraseña.';
                        }
                        return null;
                      },
                      onFieldSubmitted: (_) {
                        _login(context);
                      },
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordObscure ? Icons.visibility : Icons.visibility_off,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordObscure = !_isPasswordObscure;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    CustomButton(
                      text: 'Iniciar Sesión',
                      onPressed: () => _login(context),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        // Aquí puedes redirigir al usuario a la página de recuperación de contraseña
                        Navigator.pushNamed(context, Routes.forgotPassword);
                      },
                      child: Text(
                        '¿Olvidó su contraseña?',
                        style: TextStyle(
                          color: Color(0xFFFF0000), // Manteniendo el color de la aplicación
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withAlpha((0.5 * 255).round()),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    const Color(0xFFFF0000),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
