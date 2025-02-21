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
      // Formateamos la fecha en formato YYYY-MM-DD (para el backend)
      String formattedDate = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      _dateBirthController.text = formattedDate;
    }
  }

  bool _isPasswordObscure = true; // Controla la visibilidad de la contraseña

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
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
                obscureText: _isPasswordObscure, // Cambia el estado de la contraseña
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
                      _isPasswordObscure = !_isPasswordObscure; // Cambia el estado
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
                maxLength: 8, // Limitar a 8 caracteres
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
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  return CustomButton(
                    text: 'Registrarse',
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        String email = _emailController.text.trim();
                        String password = _passwordController.text.trim();
                        String name = _nameController.text.trim();
                        String phoneNumber = _phoneController.text.trim();
                        String dateBirth = _dateBirthController.text.trim(); // Ya en formato YYYY-MM-DD

                        // Llamada a AuthProvider para registrar el usuario
                        String? result = await authProvider.registerWithEmail(
                          email, password, name, phoneNumber, dateBirth
                        );

                        if (mounted) {
                          if (result == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Usuario registrado exitosamente')),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $result')),
                            );
                          }
                        }
                      }
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
