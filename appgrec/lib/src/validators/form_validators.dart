String? validateEmail(String? value) {
  if (value == null || value.isEmpty) {
    return 'Este campo es requerido';
  }
  String pattern = r'^[^\s@]+@[^\s@]+\.[^\s@]+$';
  RegExp regExp = RegExp(pattern);
  if (!regExp.hasMatch(value)) {
    return 'Por favor ingrese un correo válido';
  }
  return null;
}


String? validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return 'Este campo es requerido';
  }
  if (value.length < 8) {
    return 'La contraseña debe tener al menos 8 caracteres';
  }
  String pattern = r'^(?=.*[A-Z])(?=.*\d)[A-Za-z\d@$!%*?&]{8,}$';
  RegExp regExp = RegExp(pattern);
  if (!regExp.hasMatch(value)) {
    return 'La contraseña debe tener al menos una mayúscula\nun número y un caracter especial';
  }
  return null;
}


String? validateUsername(String? value) {
  if (value == null || value.isEmpty) {
    return 'Este campo es requerido';
  }
  if (value.length < 2 || value.length > 150) {
    return 'Ingrese un nombre válido';
  }
  if (!RegExp(r'^[A-Za-zÁÉÍÓÚáéíóúñÑ\s]+$').hasMatch(value)) {
    return 'El nombre no puede contener números\nni caracteres especiales';
  }
  if (RegExp(r'\s{2,}').hasMatch(value)) {
    return 'El nombre no puede contener espacios dobles';
  }
  return null;
}



String? validatePhoneNumber(String? value) {
  if (value == null || value.isEmpty) {
    return 'Este campo es requerido';
  }

  // Verifica que el primer dígito sea 9 o 3
  if (!RegExp(r'^[93]').hasMatch(value)) {
    return 'El número debe comenzar con 9 o 3';
  }

  // Verifica que el número tenga exactamente 8 dígitos
  if (!RegExp(r'^\d{8}$').hasMatch(value)) {
    return 'El número debe tener 8 dígitos';
  }

  return null;
}


String? validateDateOfBirth(String? value) {
  if (value == null || value.isEmpty) {
    return 'Este campo es requerido';
  }

  try {
    // Convertir el valor a formato YYYY-MM-DD
    DateTime birthDate = DateTime.parse(value);
    DateTime today = DateTime.now();

    // Verificar que no sea una fecha futura
    if (birthDate.isAfter(today)) {
      return 'La fecha no puede ser en el futuro';
    }

    // Verificar que tenga al menos 18 años
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month || (today.month == birthDate.month && today.day < birthDate.day)) {
      age--; // Ajuste si el cumpleaños aún no ha pasado este año
    }

    if (age < 18) {
      return 'Debes ser mayor de 18 años';
    }
  } catch (e) {
    return 'Por favor ingrese una fecha válida en formato YYYY-MM-DD';
  }

  return null;
}
