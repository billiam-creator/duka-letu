import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:duka_letu/main.dart';
import 'package:duka_letu/providers/theme_provider.dart';
import 'package:duka_letu/providers/cart_provider.dart';
import 'package:duka_letu/providers/auth_provider.dart' as custom_auth;
import 'package:duka_letu/screens/welcome_screen.dart';
import 'package:duka_letu/screens/login_screen.dart';


void main() {
  testWidgets('App starts with WelcomeScreen and navigates to LoginScreen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => CartProvider()),
          ChangeNotifierProvider(create: (_) => custom_auth.AuthProvider()),
        ],
        child: const MyApp(),
      ),
    );

    // Verify that the WelcomeScreen is displayed.
    expect(find.byType(WelcomeScreen), findsOneWidget);

    // Tap the 'Get Started' button.
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    // The app should navigate to the LoginScreen.
    expect(find.byType(LoginScreen), findsOneWidget);
  });
}