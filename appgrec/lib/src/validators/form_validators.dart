
String? validateEmail(String? value) {
  if (value == null || value.isEmpty) {
    return 'Este campo es obligatorio';
  }
  String pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$';
  RegExp regExp = RegExp(pattern);
  if (!regExp.hasMatch(value)) {
    return 'Por favor ingrese un correo válido';
  }
  return null;
}

String? validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return 'Este campo es obligatorio';
  }
  if (value.length < 8) {
    return 'La contraseña debe tener al menos 8 caracteres';
  }
  String pattern = r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*(),.?":{}|<>]).+$';
  RegExp regExp = RegExp(pattern);
  if (!regExp.hasMatch(value)) {
    return 'La contraseña debe contener al menos una letra minúscula, una letra mayúscula, un número y un carácter especial';
  }
  return null;
}


String? validateUsername(String? value) {
  if (value == null || value.isEmpty) {
    return 'Este campo es obligatorio';
  }
  return null;
}

String? validatePhoneNumber(String? value) {
  if (value == null || value.isEmpty) {
    return null; // No es obligatorio, por lo que no se realiza validación si está vacío
  }
  String pattern = r'^[3-9][0-9]{7}$';
  RegExp regExp = RegExp(pattern);
  if (!regExp.hasMatch(value)) {
    return 'Por favor ingrese un número de teléfono válido';
  }
  return null;
}


