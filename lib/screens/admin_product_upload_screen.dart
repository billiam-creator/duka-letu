// lib/screens/admin_product_upload_screen.dart

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

class AdminProductUploadScreen extends StatefulWidget {
  const AdminProductUploadScreen({super.key});

  @override
  State<AdminProductUploadScreen> createState() => _AdminProductUploadScreenState();
}

class _AdminProductUploadScreenState extends State<AdminProductUploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _categoryController = TextEditingController();

  File? _selectedImage;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadProduct() async {
    if (_formKey.currentState!.validate() && _selectedImage != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        final cloudinary = CloudinaryPublic(
          'YOUR_CLOUD_NAME', // Replace with your Cloudinary Cloud Name
          'YOUR_UPLOAD_PRESET', // Replace with your Cloudinary Upload Preset
          cache: false,
        );

        final response = await cloudinary.uploadFile(
          CloudinaryFile.fromFile(_selectedImage!.path, folder: 'products'),
        );

        final imageUrl = response.secureUrl;

        await FirebaseFirestore.instance.collection('products').add({
          'name': _nameController.text.trim(),
          'price': double.parse(_priceController.text.trim()),
          'imageUrl': imageUrl,
          'category': _categoryController.text.trim(),
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product uploaded successfully!')),
        );

        // Clear the form
        _nameController.clear();
        _priceController.clear();
        _imageUrlController.clear();
        _categoryController.clear();
        setState(() {
          _selectedImage = null;
          _isLoading = false;
        });

      } catch (error) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload product: $error')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload New Product'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Product Name'),
                validator: (value) => value!.isEmpty ? 'Please enter a product name.' : null,
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Please enter a price.' : null,
              ),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Category'),
                validator: (value) => value!.isEmpty ? 'Please enter a category.' : null,
              ),
              const SizedBox(height: 20),
              _selectedImage != null
                  ? Image.file(_selectedImage!, height: 200)
                  : const Text('No image selected.'),
              TextButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.photo_library),
                label: const Text('Select Image'),
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _uploadProduct,
                      child: const Text('Upload Product'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}