import 'package:appgrec/src/widgets/custom_appbar.dart';
import 'package:appgrec/src/widgets/custom_buttons_prim.dart';
import 'package:appgrec/src/widgets/custom_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:appgrec/src/providers/auth.dart';
import 'package:appgrec/src/routes/routes.dart';
import 'package:appgrec/src/widgets/custom_snackbar.dart'; // Asegúrate de importar el archivo con el widget de Snackbar

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

      if (!mounted) return;  // Verificar si el widget sigue montado

      setState(() {
        _isLoading = false;
      });

      if (error != null) {
        // Usando el widget personalizado de Snackbar
        CustomSnackbar.showError(context, error);
      } else {
        // Ahora obtenemos el rol del usuario
        await authProvider.fetchUserRole();

        if (!mounted) return;  // Verificar si el widget sigue montado

        // Comprobamos el rol del usuario
        String? role = authProvider.userRole;

        if (role == null) {
          CustomSnackbar.showError(context, "No se pudo obtener el rol del usuario.");
        } else {
          // Redirigimos a la pantalla correspondiente según el rol
          if (role == '1' || role =='2') { // Administrador o moderador
            Navigator.pushReplacementNamed(context, '/admin_dashboard_client');  
          } else if (role == '3') { // Cliente
            Navigator.pushReplacementNamed(context, '/client_home');  // /client_home //view_prizes
          } else {
            CustomSnackbar.showError(context, "Rol desconocido.");
          }
        }
      }
    }
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
                        fontFamily: 'TitilliumWeb',
                        fontWeight: FontWeight.w600, // SemiBold
                        fontSize: 24,
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
                          fontFamily: 'TitilliumWeb',
                          fontWeight: FontWeight.w600, // SemiBold
                          color: Color(0xFFFF0000), // Manteniendo el color de la aplicación
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
                  valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFFFF0000)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
