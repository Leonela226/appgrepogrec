import 'package:appgrec/src/providers/forgot_password.dart';
import 'package:appgrec/src/views/admin/dashboard.dart';
import 'package:appgrec/src/views/admin/dashboard_client.dart';
import 'package:appgrec/src/views/client/home.dart';
import 'package:appgrec/src/views/common/profile_users.dart';
import 'package:appgrec/src/views/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:appgrec/src/views/auth/login_page.dart';
import 'package:appgrec/src/views/auth/register_page.dart';
import 'package:appgrec/src/routes/routes.dart';

Map<String, Widget Function(BuildContext)> appRoutes = {
  Routes.welcome: (_) => const WelcomeScreen(),
  Routes.login: (_) => const LoginPage(),
  Routes.register: (_) => const RegisterPage(),
  Routes.forgotPassword: (_) => const ForgotPasswordPage(),
  Routes.profileusers: (_) => const ProfileUsers(),
  Routes.clientHome: (_) => const ClientHomeScreen(),
  Routes.adminDashboard: (_) => const AdminDashboardScreen(),
  Routes.dashboardAdminClient: (_) =>  DashboardAdminClientScreen(),
};