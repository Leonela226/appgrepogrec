import 'package:appgrec/src/providers/forgot_password.dart';
import 'package:appgrec/src/views/admin/dashboard.dart';
import 'package:appgrec/src/views/admin/dashboard_client.dart';
import 'package:appgrec/src/views/admin/profile_admin.dart';
import 'package:appgrec/src/views/admin/start_giveaway.dart';
import 'package:appgrec/src/views/admin/user_management.dart';
import 'package:appgrec/src/views/admin/view_giveaways.dart';
import 'package:appgrec/src/views/admin/view_prizes.dart';
import 'package:appgrec/src/views/client/home.dart';
import 'package:appgrec/src/views/client/scanner.dart';
import 'package:appgrec/src/views/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:appgrec/src/views/auth/login_page.dart';
import 'package:appgrec/src/views/auth/register_page.dart';
import 'package:appgrec/src/routes/routes.dart';

Map<String, Widget Function(BuildContext)> appRoutes = {
  Routes.welcome: (_) => const WelcomeScreen(),
  Routes.login: (_) => const LoginPage(),
  Routes.register: (context) => RegisterPage(
      isAdmin: ModalRoute.of(context)?.settings.arguments as bool? ?? false),
  Routes.forgotPassword: (_) => const ForgotPasswordPage(),
  Routes.profileAdminScreen: (_) => const ProfileAdminScreen(),
  Routes.clientHome: (_) => const ClientHomeScreen(),
  Routes.clientQRscan: (_) => const ClientQRScanScreen(),
  Routes.adminDashboard: (_) => const AdminDashboardScreen(),
  Routes.dashboardAdminClient: (_) => const DashboardAdminClientScreen(),
  Routes.viewPrizesScreen: (_) => const ViewPrizesScreen(),
  Routes.viewGiveawaysScreen: (_) => const ViewGiveawaysScreen(),
  Routes.userManagementScreen: (_) =>const UserManagementScreen(),
  Routes.startGiveawayScreen: (_) => const StartGiveawayScreen(),
};