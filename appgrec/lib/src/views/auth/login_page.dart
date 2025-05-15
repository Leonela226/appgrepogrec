import 'package:appgrec/src/widgets/custom_appbar.dart';
import 'package:appgrec/src/widgets/custom_buttons_prim.dart';
import 'package:appgrec/src/widgets/custom_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:appgrec/src/providers/auth.dart';
import 'package:appgrec/src/routes/routes.dart';
import 'package:appgrec/src/widgets/custom_snackbar.dart';

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

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (error != null) {
        if (!mounted) return;
        CustomSnackbar.showError(context, error);
      } else {
        await authProvider.fetchUserRole();
        if (!mounted) return;

        String? role = authProvider.userRole;

        if (role == null) {
          CustomSnackbar.showError(context, "No se pudo obtener el rol del usuario.");
        } else {
          if (authProvider.userStatus == 'inactivo') {
            CustomSnackbar.showError(context, "Tu cuenta ha sido desactivada.");
            return;
          }

          if (role == '1') {
            Navigator.pushReplacementNamed(context, '/admin_dashboard_client');
          } else if (role == '2') {
            Navigator.pushReplacementNamed(context, '/client_home');
          } else {
            CustomSnackbar.showError(context, "Rol desconocido.");
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: const CustomAppBar(),
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Inicio de Sesión',
                        style: TextStyle(
                          fontFamily: 'TitilliumWeb',
                          fontWeight: FontWeight.w600,
                          fontSize: size.width * 0.06, // tamaño proporcional
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: size.height * 0.03),
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
                      SizedBox(height: size.height * 0.02),
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
                      SizedBox(height: size.height * 0.03),
                      CustomButton(
                        text: 'Iniciar Sesión',
                        onPressed: () => _login(context),
                      ),
                      SizedBox(height: size.height * 0.02),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, Routes.forgotPassword);
                        },
                        child: Text(
                          '¿Olvidó su contraseña?',
                          style: TextStyle(
                            fontFamily: 'TitilliumWeb',
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFFF0000),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withAlpha((0.5 * 255).round()),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF0000)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
