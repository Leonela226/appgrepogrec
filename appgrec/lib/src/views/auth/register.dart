import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:appgrec/src/utils/auth/auth.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: _RegisterForm(),
        ),
      ),
    );
  }
}

class _RegisterForm extends StatefulWidget {
  const _RegisterForm();

  @override
  State<_RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<_RegisterForm> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  DateTime? _selectedDate;

  /// Seleccionar fecha de nacimiento
  Future<void> _selectDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
        _dobController.text = '${_selectedDate!.toLocal()}'.split(' ')[0];
      });
    }
  }

  /// Registrar usuario
  void _registerUser() async {
    if (_formKey.currentState?.validate() ?? false) {
      User? user = await _authService.registerWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        context: context,
      );

      if (user != null) {
        // Mostrar el snackbar en la página de registro
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Registro exitoso. Verifica tu correo electrónico.")),
        );
        Navigator.pop(context); // Navegar atrás después del registro
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildTextField(
            controller: _nameController,
            label: "Nombre completo",
            icon: Icons.person,
            validator: (value) =>
                value == null || value.isEmpty ? 'Ingresa tu nombre' : null,
          ),
          _buildTextField(
            controller: _emailController,
            label: "Correo electrónico",
            icon: Icons.email,
            validator: (value) =>
                value == null || value.isEmpty ? 'Ingresa tu correo' : null,
          ),
          _buildTextField(
            controller: _passwordController,
            label: "Contraseña",
            icon: Icons.lock,
            obscureText: true,
            validator: (value) =>
                value == null || value.isEmpty ? 'Ingresa tu contraseña' : null,
          ),
          _buildTextField(
            controller: _phoneController,
            label: "Número de celular",
            icon: Icons.phone,
            keyboardType: TextInputType.phone,
            validator: (value) =>
                value == null || value.isEmpty ? 'Ingresa tu número' : null,
          ),
          TextFormField(
            controller: _dobController,
            readOnly: true,
            decoration: const InputDecoration(
              labelText: 'Fecha de nacimiento',
              filled: true,
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.calendar_today),
            ),
            onTap: () => _selectDate(context),
            validator: (value) =>
                value == null || value.isEmpty ? 'Selecciona tu fecha' : null,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _registerUser,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: Colors.blueAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Registrar', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          border: OutlineInputBorder(),
          prefixIcon: Icon(icon),
        ),
        validator: validator,
      ),
    );
  }
}
