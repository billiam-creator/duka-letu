import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:duka_letu/models/product.dart';
import 'package:duka_letu/services/cloudinary_service.dart'; // <--- NEW IMPORT

class AddEditProductScreen extends StatefulWidget {
  final Product? product; 

  const AddEditProductScreen({super.key, this.product});

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  
  // State variables for image management
  String? _currentImageUrl; // URL for existing or uploaded image
  File? _pickedImageFile;    // File chosen from device
  
  bool _isLoading = false;
  final _cloudinaryService = CloudinaryService(); // Instantiate the service

  @override
  void initState() {
    super.initState();
    // Pre-fill fields if in Edit mode
    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _descriptionController.text = widget.product!.description;
      _priceController.text = widget.product!.price.toString();
      _quantityController.text = widget.product!.quantity.toString();
      _currentImageUrl = widget.product!.imageUrl; // Set the existing URL
    }
  }

  // ... (dispose method remains the same) ...
  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }


  // Function to pick an image
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);

    if (pickedFile != null) {
      setState(() {
        _pickedImageFile = File(pickedFile.path);
      });
    }
  }

  // Function to handle save logic, including image upload
  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    // Validate image presence only if adding or replacing
    if (_pickedImageFile == null && _currentImageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image for the product.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    String finalImageUrl = _currentImageUrl ?? '';

    try {
      // 1. UPLOAD IMAGE if a new file was picked
      if (_pickedImageFile != null) {
        final uploadUrl = await _cloudinaryService.uploadImage(_pickedImageFile!);
        if (uploadUrl == null) {
          throw Exception('Image upload to Cloudinary failed.');
        }
        finalImageUrl = uploadUrl;
      }
      
      // 2. PREPARE FIRESTORE DATA
      final name = _nameController.text;
      final description = _descriptionController.text;
      final price = double.parse(_priceController.text);
      final quantity = int.parse(_quantityController.text);
      
      final productData = {
        'name': name,
        'description': description,
        'price': price,
        'quantity': quantity,
        'imageUrl': finalImageUrl,
        // Only set creation time for new products
        if (widget.product == null) 'createdAt': FieldValue.serverTimestamp(),
      };

      // 3. SAVE TO FIRESTORE
      if (widget.product == null) {
        await FirebaseFirestore.instance.collection('products').add(productData);
      } else {
        await FirebaseFirestore.instance
            .collection('products')
            .doc(widget.product!.id)
            .update(productData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Product ${widget.product == null ? 'added' : 'updated'} successfully!')),
        );
        Navigator.of(context).pop(); 
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save product: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.product != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Product' : 'Add New Product'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Image Display and Picker Button
                    _buildImageInput(),
                    const SizedBox(height: 20),

                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Product Name'),
                      validator: (value) => value!.isEmpty ? 'Please enter a name.' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(labelText: 'Description'),
                      maxLines: 3,
                      validator: (value) => value!.isEmpty ? 'Please enter a description.' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(labelText: 'Price (\$)', prefixText: '\$'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value!.isEmpty) return 'Please enter a price.';
                        if (double.tryParse(value) == null) return 'Invalid price.';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _quantityController,
                      decoration: const InputDecoration(labelText: 'Quantity/Stock'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value!.isEmpty) return 'Please enter quantity.';
                        if (int.tryParse(value) == null) return 'Invalid quantity.';
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _saveProduct,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                      child: Text(isEditing ? 'Update Product' : 'Add Product'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
  
  Widget _buildImageInput() {
    final imageWidget = _pickedImageFile != null
        ? Image.file(_pickedImageFile!, fit: BoxFit.cover)
        : _currentImageUrl != null
            ? Image.network(_currentImageUrl!, fit: BoxFit.cover)
            : Container(color: Colors.grey[200], child: const Icon(Icons.image, size: 50, color: Colors.grey));

    return Column(
      children: [
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: imageWidget,
          ),
        ),
        TextButton.icon(
          onPressed: _pickImage,
          icon: const Icon(Icons.photo_library),
          label: Text(_pickedImageFile != null ? 'Change Image' : 'Select Image'),
        ),
      ],
    );
  }
}