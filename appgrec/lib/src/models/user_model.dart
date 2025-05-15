// src/models/user_model.dart

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }
}

class UserModel {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String birthDate;
  final String? role;
  String? status;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.birthDate,
    this.role,
    this.status,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      birthDate: json['birthDate'],
      role: json['role'],// puede ser null
      status: json['status'] != null ? (json['status'] as String).capitalize() : null,

    );
  }
}
