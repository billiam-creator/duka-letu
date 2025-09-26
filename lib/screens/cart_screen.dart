import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:duka_letu/providers/cart_provider.dart';
import 'package:duka_letu/widgets/cart_item_widget.dart'; // Ensure you have this widget

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    // CRITICAL: Access the map using .items (NOT .cartItems)
    final cartItemsList = cartProvider.items.values.toList(); 

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
      ),
      body: cartProvider.items.isEmpty // FIX 1: Use .items
          ? const Center(
              child: Text(
                'Your cart is empty. Start shopping!',
                style: TextStyle(fontSize: 18),
              ),
            )
          : Column(
              children: <Widget>[
                Expanded(
                  child: ListView.builder(
                    // CRITICAL: Use cartItemsList, which is the values of the map
                    itemCount: cartItemsList.length, 
                    itemBuilder: (ctx, index) {
                      final item = cartItemsList[index]; // FIX 2: Use the prepared list
                      return CartItemWidget(
                        cartItem: item,
                        // Pass removal functions here if CartItemWidget needs them
                      );
                    },
                  ),
                ),
                Card(
                  margin: const EdgeInsets.all(15),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        const Text(
                          'Total',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Chip(
                          label: Text(
                            '\$${cartProvider.totalPrice.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          backgroundColor: Theme.of(context).colorScheme.primary,
                        ),
                        TextButton(
                          onPressed: () {
                            // Navigate to Checkout Screen
                            Navigator.of(context).pushNamed('/checkout');
                          },
                          child: const Text('CHECKOUT'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
    );
  }
}