import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:duka_letu/providers/auth_provider.dart';
import 'package:duka_letu/services/cloudinary_service.dart';

class ProfileScreen extends StatefulWidget {
  static const routeName = '/profile';
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Uint8List? _imageBytes;       // ✅ Web-safe: bytes instead of File
  String _imageFileName = 'profile.jpg';
  bool _isUploading = false;
  final _cloudinaryService = CloudinaryService();

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _imageFileName = pickedFile.name;
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_imageBytes == null) return;
    setState(() => _isUploading = true);

    try {
      final imageUrl = await _cloudinaryService.uploadImageBytes(
        _imageBytes!,
        _imageFileName,
      );

      if (imageUrl == null) throw Exception('Upload failed. Please try again.');

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final error = await authProvider.updateProfilePicture(imageUrl);

      if (!mounted) return;

      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
      } else {
        setState(() => _imageBytes = null); // clear local preview, show network image
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile picture updated! ✓'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Build the avatar image provider — web-safe
    ImageProvider avatarImage;
    if (_imageBytes != null) {
      avatarImage = MemoryImage(_imageBytes!);  // ✅ Web-safe preview
    } else if (user?.photoURL != null && user!.photoURL!.isNotEmpty) {
      avatarImage = NetworkImage(user.photoURL!);
    } else {
      avatarImage = const AssetImage('assets/images/logo.png');
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            tooltip: 'Logout',
            onPressed: () async {
              await authProvider.logout();
              if (!mounted) return;
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Avatar with edit button
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colorScheme.primary.withOpacity(0.3),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.shadow.withOpacity(0.1),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 65,
                    backgroundImage: avatarImage,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                  ),
                ),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: colorScheme.surface, width: 2),
                    ),
                    child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Name / email
            Text(
              user?.displayName ?? user?.email?.split('@').first ?? 'User',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              user?.email ?? 'No email',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),

            const SizedBox(height: 32),

            // Upload button — only shown when new image is picked
            if (_imageBytes != null)
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.memory(
                            _imageBytes!,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'New photo selected. Tap upload to save.',
                            style: TextStyle(
                              fontSize: 13,
                              color: colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: _isUploading ? null : _uploadImage,
                    icon: _isUploading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.cloud_upload_outlined),
                    label: Text(_isUploading ? 'Uploading...' : 'Upload Photo'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => setState(() => _imageBytes = null),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(height: 16),
                ],
              ),

            // Profile info card
            Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colorScheme.outline.withOpacity(0.15)),
              ),
              child: Column(
                children: [
                  _profileTile(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: user?.email ?? 'Not set',
                    context: context,
                  ),
                  Divider(height: 1, color: colorScheme.outline.withOpacity(0.15)),
                  _profileTile(
                    icon: Icons.verified_user_outlined,
                    label: 'Account Status',
                    value: user?.emailVerified == true ? 'Verified ✓' : 'Not verified',
                    valueColor: user?.emailVerified == true ? Colors.green : Colors.orange,
                    context: context,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            OutlinedButton.icon(
              onPressed: () async {
                await authProvider.logout();
                if (!mounted) return;
                Navigator.pushReplacementNamed(context, '/login');
              },
              icon: const Icon(Icons.logout_outlined),
              label: const Text('Sign Out'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                foregroundColor: colorScheme.error,
                side: BorderSide(color: colorScheme.error.withOpacity(0.5)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileTile({
    required IconData icon,
    required String label,
    required String value,
    required BuildContext context,
    Color? valueColor,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 20, color: colorScheme.primary),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 11, color: colorScheme.onSurface.withOpacity(0.5))),
              Text(value,
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: valueColor ?? colorScheme.onSurface)),
            ],
          ),
        ],
      ),
    );
  }
}