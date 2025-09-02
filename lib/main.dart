import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:duka_letu/providers/theme_provider.dart';
import 'package:duka_letu/providers/cart_provider.dart';
import 'package:duka_letu/providers/auth_provider.dart' as custom_auth;
import 'package:duka_letu/screens/main_screen.dart';
import 'package:duka_letu/screens/login_screen.dart';
import 'package:duka_letu/screens/welcome_screen.dart';
import 'package:duka_letu/screens/admin_dashboard_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => custom_auth.AuthProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Duka Letu',
      debugShowCheckedModeBanner: false,
      theme: themeProvider.themeData,
      home: const WelcomeScreen(),
      routes: {
        '/main': (context) => const MainScreen(),
        '/login': (context) => const LoginScreen(),
        '/admin-dashboard': (context) => const AdminDashboardScreen(),
      },
      builder: (context, child) {
        return Consumer<custom_auth.AuthProvider>(
          builder: (context, authProvider, _) {
            if (authProvider.isLoading) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
            if (authProvider.user != null) {
              if (authProvider.userRole == 'admin') {
                return const AdminDashboardScreen();
              }
              return const MainScreen();
            }
            return const LoginScreen();
          },
        );
      },
    );
  }
}