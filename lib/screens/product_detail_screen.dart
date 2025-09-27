import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:duka_letu/models/product.dart';
import 'package:duka_letu/providers/cart_provider.dart';

class ProductDetailScreen extends StatelessWidget {
  static const routeName = '/product-detail';
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 300,
              width: double.infinity,
              child: Image.network(
                product.imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.error, size: 40)),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Ksh ${product.price.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                product.description,
                textAlign: TextAlign.justify,
                softWrap: true,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          cartProvider.addItem(product);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${product.name} added to cart!'),
              duration: const Duration(seconds: 2),
            ),
          );
        },
        label: const Text('Add to Cart'),
        icon: const Icon(Icons.shopping_cart),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
