import 'package:appgrec/src/views/client/home.dart';
import 'package:appgrec/src/views/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:appgrec/src/views/auth/login_page.dart';
import 'package:appgrec/src/views/auth/register_page.dart';
import 'package:appgrec/src/routes/routes.dart';

Map<String, Widget Function(BuildContext)> appRoutes = {
  Routes.login: (_) => const LoginPage(),
  Routes.register: (_) => const RegisterPage(),
  Routes.home: (_) => const HomeScreen(),
  Routes.welcome: (_) => const WelcomeScreen()
};