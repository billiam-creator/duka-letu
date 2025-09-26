import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// 🚨 CRITICAL: REPLACE THIS WITH YOUR ACTUAL ADMIN EMAIL!
const String kAdminEmail = 'admin@dukaletu.com'; // Example admin email

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  String? _userRole;
  bool _isLoading = true;

  User? get user => _user;
  String? get userRole => _userRole;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  // --- Auth State Handler ---
  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    _user = firebaseUser;
    if (firebaseUser != null) {
      if (firebaseUser.email == kAdminEmail) {
        _userRole = 'admin';
      } else {
        await _fetchUserRole(firebaseUser.uid);
      }
    } else {
        _userRole = null;
    }
    _isLoading = false;
    notifyListeners();
  }
  
  // --- Role Fetching ---
  Future<void> _fetchUserRole(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data();
        _userRole = data?['role'] as String? ?? 'user';
      } else {
        _userRole = 'user'; 
      }
    } catch (e) {
      debugPrint('Error fetching user role: $e');
      _userRole = 'user';
    }
    notifyListeners();
  }

  // --- Sign Up (Email/Password) ---
  Future<String?> signUp(String email, String password, String username) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await credential.user?.updateDisplayName(username);
      
      String role = (email == kAdminEmail) ? 'admin' : 'user';

      await FirebaseFirestore.instance.collection('users').doc(credential.user!.uid).set({
        'username': username,
        'email': email,
        'role': role,
        'profilePictureUrl': '',
      });
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // --- Sign In (Email/Password) ---
  Future<String?> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // --- Sign In (Google) ---
  Future<String?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        return 'Sign in aborted by user.';
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? signedInUser = userCredential.user;

      if (signedInUser != null && userCredential.additionalUserInfo?.isNewUser == true) {
        String role = (signedInUser.email == kAdminEmail) ? 'admin' : 'user';
        
        await FirebaseFirestore.instance.collection('users').doc(signedInUser.uid).set({
          'username': signedInUser.displayName ?? '',
          'email': signedInUser.email ?? '',
          'role': role,
          'profilePictureUrl': signedInUser.photoURL ?? '',
        });
      }

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }


  // --- Profile Picture Update (Used by ProfileScreen) ---
  Future<void> updateProfilePicture(String imageUrl) async {
    if (_user == null) return;
    try {
      await FirebaseFirestore.instance.collection('users').doc(_user!.uid).update({
        'profilePictureUrl': imageUrl,
      });
      await _user!.updatePhotoURL(imageUrl); 
      notifyListeners(); 
    } catch (e) {
      debugPrint('Error updating profile picture: $e');
      rethrow;
    }
  }

  // --- Sign Out ---
  Future<void> signOut() async {
    await _auth.signOut();
    await GoogleSignIn().signOut();
    notifyListeners();
  }
}