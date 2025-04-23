import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  void _navigateIfNeeded(BuildContext context, String route) {
    if (ModalRoute.of(context)?.settings.name != route) {
      Navigator.pushNamed(context, route);
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
            leading: Icon(Icons.leaderboard, color: Color(0xFF434244)),
            title: Text(
              'Panel Principal',
              style: TextStyle(
                fontFamily: 'TitilliumWeb',
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: () => _navigateIfNeeded(context, '/admin_dashboard'),
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
            onTap: () => _navigateIfNeeded(context, '/profile_users'),
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
            onTap: () {
              // Aquí puedes agregar la lógica para cerrar sesión
            },
          ),
        ],
      ),
    );
  }
}
