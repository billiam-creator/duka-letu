import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDark = false;

  ThemeData get currentTheme =>
      _isDark ? ThemeData.dark(useMaterial3: true) : ThemeData.light(useMaterial3: true);

  bool get isDark => _isDark;

  void toggleTheme() {
    _isDark = !_isDark;
    notifyListeners();
  }
}
