import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart'; 
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/mpesa_provider.dart';
import 'providers/theme_provider.dart';

import 'screens/welcome_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/main_screen.dart';

// Import all required screens (even if not directly routed here)
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/checkout_screen.dart';
import 'screens/add_edit_product_screen.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MultiProvider setup
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => MpesaProvider()), // M-Pesa provider
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Duka Letu E-commerce',
            theme: themeProvider.currentTheme,
            home: const AppRoot(),
            // Define named routes for easier navigation
            routes: {
              '/login': (context) => const LoginScreen(),
              '/main': (context) => const MainScreen(),
              '/admin': (context) => const AdminDashboardScreen(),
              '/checkout': (context) =>  CheckoutScreen(),
              '/add_edit_product': (context) => const AddEditProductScreen(),
            },
          );
        },
      ),
    );
  }
}


class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  // CRITICAL ROUTING LOGIC
  Widget _getInitialScreen(
      BuildContext context, AuthProvider authProvider) {
    
    if (authProvider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    // 1. Logged OUT: Welcome screen
    if (authProvider.user == null) {
      return const WelcomeScreen();
    }

    // 2. Logged IN as ADMIN: Admin Dashboard
    if (authProvider.userRole == 'admin') {
      return const AdminDashboardScreen();
    }
    
    // 3. Logged IN as USER: Main App UI
    return const MainScreen();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return _getInitialScreen(context, authProvider);
  }
}