// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/mpesa_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/product_provider.dart';

import 'widgets/main_wrapper.dart'; // ✅ Handles role-based navigation
import 'screens/login_screen.dart';
import 'screens/main_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/checkout_screen.dart';
import 'screens/add_edit_product_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/profile_screen.dart';

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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => MpesaProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Duka Letu E-commerce',
            theme: themeProvider.currentTheme,
            debugShowCheckedModeBanner: false,

            // ✅ Root handled by MainWrapper → decides where to go
            home: const MainWrapper(),

            // ✅ Named routes for easy navigation
            routes: {
              '/login': (context) => const LoginScreen(),
              '/home': (context) => const MainScreen(),
              '/admin-dashboard': (context) =>
                  const AdminDashboardScreen(),
              '/checkout': (context) => const CheckoutScreen(),
              '/add-edit-product': (context) =>
                  const AddEditProductScreen(),
              '/profile': (context) => const ProfileScreen(),
            },

            // ✅ Handles dynamic routes like product details
            onGenerateRoute: (settings) {
              if (settings.name == ProductDetailScreen.routeName) {
                final product = settings.arguments;
                if (product != null) {
                  return MaterialPageRoute(
                    builder: (ctx) =>
                        ProductDetailScreen(product: product as dynamic),
                  );
                }
              }
              return null;
            },
          );
        },
      ),
    );
  }
}
