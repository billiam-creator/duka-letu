import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:duka_letu/providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  static const routeName = '/profile';

  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_imageFile == null) return;
    setState(() => _isUploading = true);

    try {
      // ❗ Replace this with Firebase Storage or Cloudinary
      final imageUrl = "https://via.placeholder.com/150"; // mock URL

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final errorMessage = await authProvider.updateProfilePicture(imageUrl);

      if (!mounted) return;

      if (errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile picture updated!")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Upload failed: $e")),
      );
    }

    setState(() => _isUploading = false);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.logout();
              if (!mounted) return;
              Navigator.pushReplacementNamed(context, '/login');
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: _imageFile != null
                        ? FileImage(_imageFile!)
                        : (user?.photoURL != null
                            ? NetworkImage(user!.photoURL!)
                            : const AssetImage('assets/images/logo.png'))
                        as ImageProvider,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt, size: 28),
                      onPressed: _pickImage,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              user?.email ?? "No email",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            if (_imageFile != null)
              ElevatedButton.icon(
                onPressed: _isUploading ? null : _uploadImage,
                icon: _isUploading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.upload),
                label: Text(_isUploading ? "Uploading..." : "Upload"),
              ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text("Logout"),
              onPressed: () async {
                await authProvider.logout();
                if (!mounted) return;
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
    );
  }
}
