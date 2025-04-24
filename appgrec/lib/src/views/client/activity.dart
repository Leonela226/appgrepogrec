import 'package:appgrec/src/routes/routes.dart';
import 'package:appgrec/src/widgets/custom_appbar.dart';
import 'package:appgrec/src/widgets/custom_bottom_nav_bar.dart';
import 'package:appgrec/src/widgets/custom_buttons_prim.dart';
import 'package:flutter/material.dart';

class ActivityHistoryScreen extends StatelessWidget {
  const ActivityHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(automaticallyImplyLeading: false),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Historial de Actividad',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                fontFamily: 'TitilliumWeb', // Fuente aplicada
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 50),
            // Historial de participaciones
            const Text(
              'Historial de participaciones',
              style: TextStyle(
                fontFamily: 'TitilliumWeb',
                fontWeight: FontWeight.w400,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            CustomButton(
              text: 'Ver',
              onPressed: () {
               Navigator.pushNamed(context, Routes.participationHistoryScreen);
              },
            ),
            const SizedBox(height: 30),

            // Historial de premios ganados
            const Text(
              'Historial de premios ganados',
              style: TextStyle(
                fontFamily: 'TitilliumWeb',
                fontWeight: FontWeight.w400,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            CustomButton(
              text: 'Ver',
              onPressed: () {
                Navigator.pushNamed(context, Routes.historyPrizesScreen);
              },
            ),
            const SizedBox(height: 30),
            // Ganadores recientes
            const Text(
              'Ganadores recientes',
              style: TextStyle(
                fontFamily: 'TitilliumWeb',
                fontWeight: FontWeight.w400,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            CustomButton(
              text: 'Ver',
              onPressed: () {
                // Navegar a pantalla de ganadores recientes
              },
            ),
          ],
        ),

      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }
}
