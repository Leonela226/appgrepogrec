import 'package:appgrec/src/validators/form_validators.dart';
import 'package:appgrec/src/widgets/custom_appbar.dart';
import 'package:appgrec/src/widgets/custom_button.dart';
import 'package:appgrec/src/widgets/custom_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:appgrec/src/providers/auth.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  RegisterPageState createState() => RegisterPageState();
}

class RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dateBirthController = TextEditingController();

  // Crear FocusNode para cada campo de texto
  final _nameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _phoneFocusNode = FocusNode();
  final _dateBirthFocusNode = FocusNode();

  bool _isPasswordObscure = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _dateBirthController.dispose();

    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _phoneFocusNode.dispose();
    _dateBirthFocusNode.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime currentDate = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(1900),
      lastDate: currentDate,
    );

    if (picked != null) {
      String formattedDate =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      _dateBirthController.text = formattedDate;
    }
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _register(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();
      String name = _nameController.text.trim();
      String phone = _phoneController.text.trim();
      String birthDate = _dateBirthController.text.trim();

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      String? result = await authProvider.registerWithEmail(
        email,
        password,
        name,
        phone,
        birthDate,
      );

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        if (result == null) {
          _showSnackBar(context, 'Usuario registrado exitosamente', Colors.green);
        } else {
          _showSnackBar(context, 'Error: $result', Colors.red);
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  const SizedBox(height: 40), // Agrega espacio antes del título
                  Text(
                    'Registro',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 24),
                  CustomTextFormField(
                    labelText: 'Nombre',
                    icon: Icons.person,
                    controller: _nameController,
                    focusNode: _nameFocusNode,
                    validator: validateUsername,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_emailFocusNode);
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextFormField(
                    labelText: 'Correo Electrónico',
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                    controller: _emailController,
                    focusNode: _emailFocusNode,
                    validator: validateEmail,
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
                    validator: validatePassword,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_phoneFocusNode);
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
                  const SizedBox(height: 16),
                  CustomTextFormField(
                    labelText: 'Número de Teléfono',
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                    controller: _phoneController,
                    focusNode: _phoneFocusNode,
                    validator: validatePhoneNumber,
                    maxLength: 8,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_dateBirthFocusNode);
                    },
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => _selectDate(context),
                    child: AbsorbPointer(
                      child: CustomTextFormField(
                        labelText: 'Fecha de Nacimiento',
                        icon: Icons.calendar_today,
                        controller: _dateBirthController,
                        focusNode: _dateBirthFocusNode,
                        validator: validateDateOfBirth,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).unfocus();
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  CustomButton(
                    text: 'Registrarse',
                    onPressed: () => _register(context),
                  ),
                ],
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
