// lib/providers/auth_provider.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  String? _userRole;
  bool _isLoading = false;

  User? get user => _user;
  String? get userRole => _userRole;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _auth.authStateChanges().listen((User? user) async {
      _user = user;
      if (_user != null) {
        await _fetchUserRole();
      } else {
        _userRole = null;
      }
      notifyListeners();
    });
  }

  Future<void> _fetchUserRole() async {
    if (_user == null) return;
    try {
      final userDoc = await _firestore.collection('users').doc(_user!.uid).get();
      if (userDoc.exists) {
        _userRole = userDoc.data()?['role'];
      }
    } catch (e) {
      print('Error fetching user role: $e');
      _userRole = null;
    }
  }

  Future<String?> signUp(String email, String password, String username) async {
    _isLoading = true;
    notifyListeners();
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user != null) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'username': username,
          'email': email,
          'role': 'user',
        });
        _user = userCredential.user;
        _userRole = 'user';
      }
      _isLoading = false;
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      return _handleAuthError(e.code);
    }
  }

  Future<String?> signIn(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = userCredential.user;
      await _fetchUserRole();
      _isLoading = false;
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      return _handleAuthError(e.code);
    }
  }

  // ADDED THIS METHOD
  Future<String?> signInWithGoogle() async {
    _isLoading = true;
    notifyListeners();
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        _isLoading = false;
        notifyListeners();
        return 'Sign-in aborted by user.';
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await _auth.signInWithCredential(credential);
      if (userCredential.user != null) {
        final userDoc = await _firestore.collection('users').doc(userCredential.user!.uid).get();
        if (!userDoc.exists) {
          await _firestore.collection('users').doc(userCredential.user!.uid).set({
            'username': userCredential.user!.displayName ?? 'New User',
            'email': userCredential.user!.email,
            'role': 'user',
          });
          _userRole = 'user';
        } else {
           _userRole = userDoc.data()?['role'];
        }
      }
      _isLoading = false;
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      return _handleAuthError(e.code);
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();
    await _auth.signOut();
    _user = null;
    _userRole = null;
    _isLoading = false;
    notifyListeners();
  }

  String? _handleAuthError(String errorCode) {
    String? errorMessage;
    switch (errorCode) {
      case 'weak-password':
        errorMessage = 'The password provided is too weak.';
        break;
      case 'email-already-in-use':
        errorMessage = 'An account already exists for that email.';
        break;
      case 'user-not-found':
        errorMessage = 'No user found for that email.';
        break;
      case 'wrong-password':
        errorMessage = 'Wrong password provided for that user.';
        break;
      case 'invalid-email':
        errorMessage = 'The email address is not valid.';
        break;
      default:
        errorMessage = 'An unknown error occurred.';
    }
    return errorMessage;
  }
}