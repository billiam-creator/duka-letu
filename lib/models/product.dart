// lib/models/product.dart

class Product {
  final String id;
  final String name;
  final String description; // <-- FIX: ADDED
  final double price;
  final int quantity; // <-- FIX: ADDED
  final String imageUrl;
  final String category;

  Product({
    required this.id,
    required this.name,
    required this.description, // <-- FIX: ADDED
    required this.price,
    required this.quantity, // <-- FIX: ADDED
    required this.imageUrl,
    required this.category,
  });

  factory Product.fromFirestore(Map<String, dynamic> data, String id) {
    return Product(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '', // <-- FIX: MAPPING
      price: (data['price'] is num) ? data['price'].toDouble() : 0.0,
      quantity: (data['quantity'] is num) ? data['quantity'].toInt() : 0, // <-- FIX: MAPPING
      imageUrl: data['imageUrl'] ?? '',
      category: data['category'] ?? 'General',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'quantity': quantity,
      'imageUrl': imageUrl,
      'category': category,
    };
  }
}