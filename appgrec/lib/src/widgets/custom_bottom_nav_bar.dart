import 'package:appgrec/src/routes/routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class CustomBottomNavBar extends StatefulWidget {
  const CustomBottomNavBar({super.key});

  @override
  CustomBottomNavBarState createState() => CustomBottomNavBarState();
}

class CustomBottomNavBarState extends State<CustomBottomNavBar> {
  int selectedIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    String currentRoute = ModalRoute.of(context)?.settings.name ?? '';
    int newIndex = 0;
    if (currentRoute == Routes.clientHome) {
      newIndex = 0;
    } else if (currentRoute == Routes.profileUsers) {
      newIndex = 1;
    } 
    // else if (currentRoute == Routes.scanner) {
    //   newIndex = 2;
    // } else if (currentRoute == Routes.sorteos) {
    //   newIndex = 3;
    // } else if (currentRoute == Routes.notifications) {
    //   newIndex = 4;
    // }

    if (newIndex != selectedIndex) {
      setState(() {
        selectedIndex = newIndex;
      });
    }
  }

  void _onItemTapped(int index) {
    String currentRoute = ModalRoute.of(context)?.settings.name ?? '';

    String? newRoute;
    switch (index) {
      case 0:
        newRoute = Routes.clientHome;
        break;
      case 1:
        newRoute = Routes.profileUsers;
        break;
      case 2:
         newRoute = Routes.clientQRscan;
      //   break;
      // case 3:
      //   newRoute = Routes.sorteos;
      //   break;
      // case 4:
      //   newRoute = Routes.notifications;
      //   break;
    }

    if (newRoute != null && currentRoute != newRoute) {
      Navigator.pushReplacementNamed(context, newRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      height: 60,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: GNav(
          rippleColor: Colors.grey[300]!,
          hoverColor: Colors.grey[100]!,
          gap: 4,
          activeColor: Colors.black,
          iconSize: 28,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          duration: const Duration(milliseconds: 400),
          tabBackgroundColor: Color.fromRGBO(67, 66, 68, 0.1), // Usamos .fromRGBO en lugar de .withOpacity
          color: Colors.grey,
          selectedIndex: selectedIndex,
          onTabChange: _onItemTapped,
          tabs: [
            GButton(icon: CupertinoIcons.home, text: 'Inicio'),
            GButton(icon: CupertinoIcons.profile_circled, text: 'Perfil'),
            GButton(icon: CupertinoIcons.camera, text: 'Escáner'), // Ruta comentada
            GButton(icon: CupertinoIcons.gift, text: 'Sorteos'), // Ruta comentada
            GButton(icon: CupertinoIcons.bell, text: 'Notificaciones'), // Ruta comentada
          ],
        ),
      ),
    );
  }
}
