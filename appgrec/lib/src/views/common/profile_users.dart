import 'package:appgrec/src/widgets/custom_appbar.dart';
import 'package:appgrec/src/widgets/custom_bottom_nav_bar.dart';
import 'package:flutter/material.dart';

class ProfileUsers extends StatelessWidget {
  const ProfileUsers({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(), // Usando el CustomAppBar aquí
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            Text(
              '¡Hola!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(), // Agregar el CustomBottomNavBar aquí
    );
  }
}
