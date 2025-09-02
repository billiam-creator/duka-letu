import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:duka_letu/providers/cart_provider.dart';
import 'package:duka_letu/providers/auth_provider.dart';
import 'package:duka_letu/screens/login_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
      ),
      body: cartProvider.cartItems.isEmpty
          ? const Center(
              child: Text(
                'Your cart is empty.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: cartProvider.cartItems.length,
              itemBuilder: (context, index) {
                final item = cartProvider.cartItems[index];
                return ListTile(
                  leading: Image.asset(item.imageUrl, width: 50, height: 50, fit: BoxFit.cover),
                  title: Text(item.name),
                  subtitle: Text('\$${item.price.toStringAsFixed(2)}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () {
                          cartProvider.decreaseQuantity(item);
                        },
                      ),
                      Text(item.quantity.toString()),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () {
                          cartProvider.increaseQuantity(item);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          cartProvider.removeFromCart(item);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            if (authProvider.isAuthenticated) {
              // User is logged in, proceed to checkout
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Proceeding to checkout...'),
                ),
              );
              // You can add navigation to a checkout page here.
            } else {
              // User is a guest, prompt to log in
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Log In Required'),
                  content: const Text('You must be logged in to proceed to checkout. Would you like to log in or sign up now?'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                        );
                      },
                      child: const Text('Log In'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            'Checkout (${cartProvider.cartItems.length}) - \$${cartProvider.totalPrice.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}