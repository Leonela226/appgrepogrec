import 'package:flutter/material.dart';
import 'package:appgrec/src/views/auth/register.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo de pantalla
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/patron1.jpg'), // Asegúrate de que la ruta de la imagen sea correcta
                fit: BoxFit.cover,
              ),
            ),
          ),
          
          // Contenido del login
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo de la aplicación
                    Image.asset(
                      'assets/images/splash.png', // Ruta del logo
                      height: 150,
                    ),
                    
                    SizedBox(height: 40),
                    
                    // Formulario de login
                    _LoginForm(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Campo de texto para el email
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Correo electrónico',
              filled: true,
              fillColor: Colors.white.withValues(alpha: 179), // Reemplazo con withValues
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.email),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa tu correo electrónico';
              }
              return null;
            },
          ),
          
          SizedBox(height: 20),
          
          // Campo de texto para la contraseña
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Contraseña',
              filled: true,
              fillColor: Colors.white.withValues(alpha: 179), // Reemplazo con withValues
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.lock),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa tu contraseña';
              }
              return null;
            },
          ),
          
          SizedBox(height: 20),
          
          // Botón de login
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState?.validate() ?? false) {
                // Aquí iría la lógica para el login
                // Por ejemplo, autenticación con Firebase
                debugPrint('Login exitoso');
              }
            },
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, 50),
              backgroundColor: Colors.blueAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Iniciar sesión', style: TextStyle(fontSize: 18)),
          ),
          
          SizedBox(height: 20),
          
          // Enlace para registro o recuperar contraseña
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {
                  // Navegar a la pantalla de registro
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RegisterPage()),
                  );
                },
                child: Text('¿No tienes cuenta? Regístrate'),
              ),
              TextButton(
                onPressed: () {
                  // Navegar a la pantalla de recuperación de contraseña
                  debugPrint('Recuperar contraseña');
                },
                child: Text('¿Olvidaste tu contraseña?'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
