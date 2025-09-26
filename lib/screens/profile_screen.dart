import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:duka_letu/providers/auth_provider.dart' as custom_auth;
import 'package:duka_letu/services/cloudinary_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final picker = ImagePicker();
  final cloudinaryService = CloudinaryService();
  bool _isUploading = false;
  
  // Placeholder for user details from Firestore
  String? _profilePictureUrl; 
  String? _username;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // Fetch the user's data (including profile picture URL) from Firestore
  Future<void> _fetchUserData() async {
    final user = Provider.of<custom_auth.AuthProvider>(context, listen: false).user;
    if (user == null) return;
    
    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if (doc.exists) {
      setState(() {
        _profilePictureUrl = doc.data()?['profilePictureUrl'] as String?;
        _username = doc.data()?['username'] as String?;
      });
    }
  }

  // Handles picking the image, uploading it, and updating Firestore
  Future<void> _handleImageChange() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 75);

    if (pickedFile != null) {
      setState(() {
        _isUploading = true;
      });

      try {
        final imageFile = File(pickedFile.path);
        // 1. Upload to Cloudinary
        final imageUrl = await cloudinaryService.uploadImage(imageFile);

        if (imageUrl != null && mounted) {
          // 2. Update Firestore via AuthProvider
          await Provider.of<custom_auth.AuthProvider>(context, listen: false).updateProfilePicture(imageUrl);
          
          // 3. Update local state for display
          setState(() {
            _profilePictureUrl = imageUrl;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile picture updated!')),
          );
        } else {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Image upload failed.')),
          );
        }
      } catch (e) {
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isUploading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<custom_auth.AuthProvider>(context);
    final firebaseUser = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: authProvider.signOut,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // --- Profile Picture Widget ---
            Stack(
              children: [
                CircleAvatar(
                  radius: 70,
                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  // Display uploaded picture or default icon
                  backgroundImage: _profilePictureUrl != null && _profilePictureUrl!.isNotEmpty
                      ? NetworkImage(_profilePictureUrl!) as ImageProvider
                      : null,
                  child: _profilePictureUrl == null || _profilePictureUrl!.isEmpty
                      ? Icon(Icons.person, size: 70, color: Theme.of(context).colorScheme.primary)
                      : null,
                ),
                if (_isUploading)
                  const Positioned.fill(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _isUploading ? null : _handleImageChange,
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: const Icon(Icons.edit, color: Colors.white, size: 18),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // --- User Details ---
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.badge),
                      title: const Text('Username'),
                      subtitle: Text(_username ?? firebaseUser?.displayName ?? 'N/A'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.email),
                      title: const Text('Email'),
                      subtitle: Text(firebaseUser?.email ?? 'N/A'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.verified_user),
                      title: const Text('Role'),
                      subtitle: Text(authProvider.userRole?.toUpperCase() ?? 'USER'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // ... (Add other profile settings here later) ...
          ],
        ),
      ),
    );
  }
}