
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
    return 'Este campo es obligatorio';
  }
  String pattern = r'^[3-9][0-9]{7}$';
  RegExp regExp = RegExp(pattern);
  if (!regExp.hasMatch(value)) {
    return 'Por favor ingrese un número de teléfono válido';
  }
  return null;
}
String? validateDateNotInFuture(String? value) {
  if (value == null || value.isEmpty) {
    return 'Este campo es obligatorio';
  }

  // Intentar analizar la fecha ingresada con formato DD/MM/YYYY
  try {
    List<String> parts = value.split('/');
    if (parts.length == 3) {
      int day = int.parse(parts[0]);
      int month = int.parse(parts[1]);
      int year = int.parse(parts[2]);

      // Validar si la fecha es válida
      if (month < 1 || month > 12 || day < 1 || day > 31) {
        return 'Por favor ingrese una fecha válida';
      }

      DateTime inputDate = DateTime(year, month, day);
      DateTime today = DateTime.now();

      if (inputDate.isAfter(today)) {
        return 'La fecha no puede ser en el futuro';
      }
    } else {
      return 'Por favor ingrese una fecha válida en formato DD/MM/YYYY';
    }
  } catch (e) {
    return 'Por favor ingrese una fecha válida';
  }

  return null;
}




