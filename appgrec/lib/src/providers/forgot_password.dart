import 'package:appgrec/src/utils/validators/form_field_validators.dart';
import 'package:appgrec/src/widgets/custom_appbar.dart';
import 'package:appgrec/src/widgets/custom_text_form_field.dart';
import 'package:appgrec/src/widgets/custom_buttons_prim.dart';
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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Método para mostrar el SnackBar con color personalizado
  void _showSnackBar(String message, {Color backgroundColor = Colors.red}) {
    if (!mounted) return;
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

    if (!mounted) return; // Verifica si el widget sigue montado

    setState(() {
      _isLoading = false;  // Desactiva el estado de carga
    });

    if (error == null) {
      _showSnackBar('Correo de recuperación enviado', backgroundColor: Colors.green);
      Navigator.pushReplacementNamed(context, '/login'); // Redirige a la página de login
    } else {
      _showSnackBar('Error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size; // Obtener el tamaño de la pantalla

    return Scaffold(
      appBar: const CustomAppBar(), // Usamos el CustomAppBar
      body: Center( // Usamos Center para asegurar el centrado del contenido
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.08), // Márgenes laterales ajustables
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400), // Limita el ancho en pantallas grandes
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,  // Centra verticalmente
                  crossAxisAlignment: CrossAxisAlignment.center,  // Centra horizontalmente
                  children: [
                    // Encabezado "Recuperación de Contraseña"
                    Text(
                      'Recuperación de Contraseña',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600, // SemiBold
                        fontFamily: 'TitilliumWeb', // Tipo de letra TitilliumWeb-SemiBold
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center, // Centra el texto
                    ),
                    SizedBox(height: size.height * 0.05), // Espaciado ajustable

                    // Campo de correo electrónico
                    CustomTextFormField(
                      controller: _emailController,
                      labelText: 'Correo Electrónico',
                      icon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        return validateEmail(value);
                      },
                    ),
                    SizedBox(height: size.height * 0.05), // Espaciado ajustable

                    // Botón de "Enviar Correo"
                    CustomButton(
                      text: _isLoading ? 'Enviando...' : 'Enviar Correo',
                      onPressed: _isLoading 
                        ? (){}  // Al estar cargando, no hace nada
                        : () {
                            _sendResetEmail();  
                          },
                    ),
                    SizedBox(height: size.height * 0.05), // Espaciado ajustable
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
