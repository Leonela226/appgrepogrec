import 'package:appgrec/src/validators/form_validators.dart';
import 'package:appgrec/src/widgets/custom_appbar.dart';
import 'package:appgrec/src/widgets/custom_text_form_field.dart';
import 'package:appgrec/src/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:appgrec/src/providers/auth.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ForgotPasswordPageState createState() => ForgotPasswordPageState();
}

class ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); // Usar una clave para el formulario
  bool _isLoading = false;

  // Método para mostrar el SnackBar con color personalizado
  void _showSnackBar(String message, {Color backgroundColor = Colors.red}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _sendResetEmail() async {
    if (!_formKey.currentState!.validate()) {
      return;  // Si el formulario no es válido, no continua
    }

    String email = _emailController.text.trim();

    setState(() {
      _isLoading = true;  // Activa el estado de carga
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    String? error = await authProvider.resetPassword(email);  // Llamamos a resetPassword

    setState(() {
      _isLoading = false;  // Desactiva el estado de carga
    });

    if (error == null) {
      _showSnackBar('Correo de recuperación enviado', backgroundColor: Colors.green); // SnackBar de éxito en verde
      Navigator.pushReplacementNamed(context, '/login'); // Redirige a la página de login
    } else {
      _showSnackBar('Error: $error'); // SnackBar de error en rojo
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(), // Usamos el CustomAppBar
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,  // Asignamos el GlobalKey al formulario
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,  // Centra verticalmente
            children: [
              // Encabezado "Recuperación de Contraseña"
              Text(
                'Recuperación de Contraseña',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center, // Centra el texto
              ),
              const SizedBox(height: 24), // Espaciado similar al login

              // Campo de correo electrónico
              CustomTextFormField(
                controller: _emailController,
                labelText: 'Correo Electrónico',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  // Usamos la función de validación para el correo
                  return validateEmail(value);
                },
              ),
              const SizedBox(height: 24), // Espaciado similar al login

              // Botón de "Enviar Correo"
              CustomButton(
                text: _isLoading ? 'Enviando...' : 'Enviar Correo',
                onPressed: _isLoading 
                  ? (){}  // Al no estar cargando, simplemente no hace nada (vacío)
                  : () {
                      _sendResetEmail();  
                    },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
