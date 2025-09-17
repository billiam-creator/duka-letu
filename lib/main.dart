// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:duka_letu/providers/theme_provider.dart';
import 'package:duka_letu/providers/cart_provider.dart';
import 'package:duka_letu/providers/auth_provider.dart' as custom_auth; // Add a prefix
import 'package:duka_letu/screens/main_screen.dart';
import 'package:duka_letu/screens/login_screen.dart';
import 'package:duka_letu/screens/welcome_screen.dart';
import 'package:duka_letu/screens/admin_dashboard_screen.dart';
import 'package:duka_letu/screens/cart_screen.dart'; // Import CartScreen
import 'package:duka_letu/screens/home_screen.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => custom_auth.AuthProvider()), // Use the prefix here
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
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          if (snapshot.hasData) {
            return const HomeScreen();
          } else {
            return const WelcomeScreen();
          }
        },
      ),
      routes: {
        '/main': (context) => const MainScreen(),
        '/login': (context) => const LoginScreen(),
        '/admin-dashboard': (context) => const AdminDashboardScreen(),
        '/cart': (context) => const CartScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}