import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:duka_letu/providers/auth_provider.dart';
import 'package:duka_letu/screens/login_screen.dart';
import 'package:duka_letu/screens/main_screen.dart';
import 'package:duka_letu/screens/admin_dashboard_screen.dart';

class MainWrapper extends StatelessWidget {
  const MainWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // 1. Loading state (while Firebase checks the user)
    if (authProvider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // 2. Not logged in → go to LoginScreen
    if (authProvider.user == null) {
      return const LoginScreen();
    }

    // 3. Logged in → check if Admin
    final email = authProvider.user!.email ?? '';
    if (email.toLowerCase() == "bushg5200@gmail.com") {
      return const AdminDashboardScreen();
    }

    // 4. Otherwise → Normal MainScreen
    return const MainScreen();
  }
}
