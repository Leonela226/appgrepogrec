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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registro de Usuario'),
      ),
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa tu nombre';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              CustomTextFormField(
                labelText: 'Correo Electrónico',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                controller: _emailController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa tu correo electrónico';
                  } else if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                    return 'Por favor ingresa un correo válido';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              CustomTextFormField(
                labelText: 'Contraseña',
                icon: Icons.lock,
                obscureText: true,
                controller: _passwordController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa una contraseña';
                  } else if (value.length < 6) {
                    return 'La contraseña debe tener al menos 6 caracteres';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              CustomTextFormField(
                labelText: 'Número de Teléfono',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                controller: _phoneController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa tu número de teléfono';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              CustomTextFormField(
                labelText: 'Fecha de Nacimiento',
                icon: Icons.calendar_today,
                keyboardType: TextInputType.datetime,
                controller: _dateBirthController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa tu fecha de nacimiento';
                  } else if (!RegExp(r'\d{2}/\d{2}/\d{4}').hasMatch(value)) {
                    return 'Formato incorrecto. Usa DD/MM/YYYY';
                  }
                  return null;
                },
              ),
              SizedBox(height: 32),
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
                        String dateBirth = _dateBirthController.text.trim();

                        // Llamada a AuthProvider para registrar el usuario
                        String? result = await authProvider.registerWithEmail(email, password);
                        if (result == null) {
                          // Éxito en el registro
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Usuario registrado exitosamente'),
                          ));
                          // Redirigir a la pantalla de inicio o login
                        } else {
                          // Error en el registro
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Error: $result'),
                          ));
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
