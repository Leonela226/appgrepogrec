import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({
    super.key,
    this.title = "App Grec",
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return AppBar(
      //automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      elevation: 4,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/splash.png',
            height: screenHeight * 0.06,
          ),
          SizedBox(width: screenWidth * 0.02),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'TitilliumWeb-Bold',
              fontSize: screenWidth * 0.05,
              color: Colors.black,
            ),
          ),
        ],
      ),
      centerTitle: true,
      iconTheme: const IconThemeData(color: Colors.black),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}


















































































/*import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showMenu; // Indica si se muestra el ícono de menú
  final List<Map<String, String>> menuItems; // Lista de elementos del menú

  const CustomAppBar({
    super.key,
    this.title = "App Grec",
    this.showMenu = false,
    this.menuItems = const [],
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      elevation: 4,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/splash.png',
            height: screenHeight * 0.06,
          ),
          SizedBox(width: screenWidth * 0.02),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'TitilliumWeb-Bold',
              fontSize: screenWidth * 0.05,
              color: Colors.black,
            ),
          ),
        ],
      ),
      centerTitle: true,
      iconTheme: const IconThemeData(color: Colors.black),
      leading: showMenu
          ? Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openDrawer(); // Abre el Drawer correctamente
                },
              ),
            )
          : null,
      actions: [
        if (menuItems.isNotEmpty)
          PopupMenuButton<String>(
            onSelected: (routeName) {
              Navigator.pushNamed(context, routeName);
            },
            itemBuilder: (BuildContext context) {
              return menuItems.map((menuItem) {
                return PopupMenuItem<String>(
                  value: menuItem['route']!,
                  child: Text(menuItem['title']!),
                );
              }).toList();
            },
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}*/
