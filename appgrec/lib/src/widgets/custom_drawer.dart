import 'package:appgrec/src/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Importa FirebaseAuth si estás utilizando Firebase

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  void _navigateIfNeeded(BuildContext context, String route) {
    if (ModalRoute.of(context)?.settings.name != route) {
      Navigator.pushNamed(context, route);
    }
  }

  // Método para cerrar sesión
  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut(); // Cerrar sesión en Firebase
      Navigator.pushReplacementNamed(context, '/login'); // Redirigir a la pantalla de login
    } catch (e) {
      // Si hay un error al cerrar sesión, muestra un CustomSnackbar
      CustomSnackbar.showError(context, 'Error al cerrar sesión: ${e.toString()}'); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Color(0xFF434244), // Color personalizado
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.account_circle,
                  size: 60,
                  color: Colors.white,
                ),
                SizedBox(height: 10),
                Text(
                  'Bienvenido',
                  style: TextStyle(
                    fontFamily: 'TitilliumWeb',
                    fontWeight: FontWeight.w600, // SemiBold
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ],
            ),
          ),
 
          ListTile(
            leading: Icon(Icons.account_circle, color: Color(0xFF434244)),
            title: Text(
              'Perfil de Usuario',
              style: TextStyle(
                fontFamily: 'TitilliumWeb',
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: () => _navigateIfNeeded(context, '/profile_users_admin'),
          ),
          ListTile(
            leading: Icon(Icons.dashboard, color: Color(0xFF434244)),
            title: Text(
              'Gestión de Vista del Cliente',
              style: TextStyle(
                fontFamily: 'TitilliumWeb',
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: () => _navigateIfNeeded(context, '/admin_dashboard_client'),
          ),
          ListTile(
            leading: Icon(Icons.people, color: Color(0xFF434244)),
            title: Text(
              'Gestión de Usuarios',
              style: TextStyle(
                fontFamily: 'TitilliumWeb',
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: () => _navigateIfNeeded(context, '/user_management'),
          ),
          ListTile(
            leading: Icon(Icons.card_giftcard, color: Color(0xFF434244)),
            title: Text(
              'Gestión de Premios',
              style: TextStyle(
                fontFamily: 'TitilliumWeb',
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: () => _navigateIfNeeded(context, '/view_prizes'),
          ),
          ListTile(
            leading: Icon(Icons.edit, color: Color(0xFF434244)),
            title: Text(
              'Gestión de Sorteos',
              style: TextStyle(
                fontFamily: 'TitilliumWeb',
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: () => _navigateIfNeeded(context, '/view_giveaways'),
          ),
          ListTile(
            leading: Icon(Icons.casino, color: Color(0xFF434244)),
            title: Text(
              'Realización de Sorteos',
              style: TextStyle(
                fontFamily: 'TitilliumWeb',
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: () => _navigateIfNeeded(context, '/start_giveaway'),
          ),
          ListTile(
            leading: Icon(Icons.emoji_events, color: Color(0xFF434244)),
            title: Text(
              'Listado de Ganadores',
              style: TextStyle(
                fontFamily: 'TitilliumWeb',
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: () => _navigateIfNeeded(context, '/'),
          ),
   
          Divider(),
          ListTile(
            leading: Icon(Icons.logout, color: Color(0xFFFF0000)),
            title: Text(
              'Cerrar Sesión',
              style: TextStyle(
                fontFamily: 'TitilliumWeb',
                fontWeight: FontWeight.w600,
                color: Color(0xFFFF0000),
              ),
            ),
            onTap: () => _logout(context), // Llamar al método _logout
          ),
        ],
      ),
    );
  }
}
