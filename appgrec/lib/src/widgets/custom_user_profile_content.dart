import 'package:appgrec/src/models/user_model.dart';
import 'package:appgrec/src/widgets/custom_buttons_sec.dart';
import 'package:appgrec/src/widgets/custom_text_form_field.dart';
import 'package:flutter/material.dart';

class UserProfileForm extends StatefulWidget {
  final UserModel user;
  final void Function(UserModel updatedUser) onSave;

  const UserProfileForm({
    super.key,
    required this.user,
    required this.onSave,
  });

  @override
  State<UserProfileForm> createState() => _UserProfileFormState();
}

class _UserProfileFormState extends State<UserProfileForm> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController birthDateController;

  bool isEditing = false; // Nuevo estado

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.user.name);
    emailController = TextEditingController(text: widget.user.email);
    phoneController = TextEditingController(text: widget.user.phone);
    birthDateController = TextEditingController(text: widget.user.birthDate);
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    birthDateController.dispose();
    super.dispose();
  }

  void _submitForm() {
    final updatedUser = UserModel(
      id: widget.user.id,
      name: nameController.text.trim(),
      email: emailController.text.trim(),
      phone: phoneController.text.trim(),
      birthDate: birthDateController.text.trim(),
    );

    widget.onSave(updatedUser);

    setState(() {
      isEditing = false; // Desactiva edición después de guardar
    });
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
      String formattedDate =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      birthDateController.text = formattedDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        const Text(
          'Perfil de Usuario',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            fontFamily: 'TitilliumWeb',
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 20),
        CustomTextFormField(
          labelText: 'Nombre',
          icon: Icons.person,
          controller: nameController,
          enabled: isEditing,
        ),
        const SizedBox(height: 16),
        CustomTextFormField(
          labelText: 'Correo electrónico',
          icon: Icons.email,
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          enabled: isEditing,
        ),
        const SizedBox(height: 16),
        CustomTextFormField(
          labelText: 'Teléfono',
          icon: Icons.phone,
          controller: phoneController,
          keyboardType: TextInputType.phone,
          enabled: isEditing,
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () => _selectDate(context),
          child: AbsorbPointer(
            child:CustomTextFormField(
          labelText: 'Fecha de nacimiento',
          icon: Icons.calendar_today,
          controller: birthDateController,
          keyboardType: TextInputType.datetime,
          enabled: isEditing,
        ), 
          )
        ),

        const SizedBox(height: 15),
        isEditing
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: CustomBottonSec(
                      text: 'Guardar',
                      onPressed: _submitForm,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomBottonSec(
                      text: 'Cancelar',
                      onPressed: () {
                        setState(() {
                          isEditing = false;
                          nameController.text = widget.user.name;
                          emailController.text = widget.user.email;
                          phoneController.text = widget.user.phone;
                          birthDateController.text = widget.user.birthDate;
                        });
                      },
                    ),
                  ),
                ],
              )
            : CustomBottonSec(
                text: 'Editar',
                onPressed: () {
                  setState(() {
                    isEditing = true;
                  });
                },
              ),
      ],
    );
  }
}
