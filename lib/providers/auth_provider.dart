// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? _user;
  String? _userRole;
  bool _isLoading = true;

  User? get user => _user;
  String? get userRole => _userRole;
  bool get isLoading => _isLoading;

  /// Hardcoded admin email
  static const String adminEmail = "bushg5200@gmail.com";

  /// ✅ Getter
  bool get isAdmin => _userRole == "admin";

  AuthProvider() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    _user = firebaseUser;
    if (_user != null) {
      _determineUserRole();
    } else {
      _userRole = null;
    }
    _isLoading = false;
    notifyListeners();
  }

  /// Hardcoded role logic
  void _determineUserRole() {
    if (_user != null && _user!.email == adminEmail) {
      _userRole = "admin";
    } else {
      _userRole = "user";
    }
  }

  Future<String?> register({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = result.user;
      _determineUserRole();
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (_) {
      return "Registration failed. Please try again.";
    }
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = result.user;
      _determineUserRole();
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (_) {
      return "Login failed. Please try again.";
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    _user = null;
    _userRole = null;
    notifyListeners();
  }

  Future<String?> updateProfilePicture(String imageUrl) async {
    try {
      await _user?.updatePhotoURL(imageUrl);
      await _user?.reload();
      _user = _auth.currentUser;
      notifyListeners();
      return null;
    } catch (e) {
      return "Failed to update profile picture: $e";
    }
  }
}
