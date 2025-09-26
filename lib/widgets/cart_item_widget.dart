import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:duka_letu/providers/cart_provider.dart';
import 'package:duka_letu/models/product.dart';

class CartItemWidget extends StatelessWidget {
  final CartItem cartItem;

  const CartItemWidget({
    super.key,
    required this.cartItem,
  });

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final Product product = cartItem.product;

    // Use a Dismissible widget to allow swiping to remove the item
    return Dismissible(
      key: ValueKey(product.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Theme.of(context).colorScheme.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 40,
        ),
      ),
      confirmDismiss: (direction) {
        // Show a confirmation dialog before fully dismissing
        return showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Are you sure?'),
            content: const Text('Do you want to remove the item from the cart?'),
            actions: <Widget>[
              TextButton(
                child: const Text('No'),
                onPressed: () => Navigator.of(ctx).pop(false),
              ),
              TextButton(
                child: const Text('Yes'),
                onPressed: () => Navigator.of(ctx).pop(true),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        // Remove the item from the cart after confirmation
        cartProvider.removeItem(product.id);
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(product.imageUrl),
              onBackgroundImageError: (exception, stackTrace) => const Icon(Icons.image),
            ),
            title: Text(product.name),
            subtitle: Text(
                'Total: \$${(product.price * cartItem.quantity).toStringAsFixed(2)}'),
            trailing: Column(
              children: [
                Text('\$${product.price.toStringAsFixed(2)}'),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Button to decrease quantity
                    InkWell(
                      onTap: () => cartProvider.removeSingleItem(product.id),
                      child: const Icon(Icons.remove_circle_outline, size: 20),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text('${cartItem.quantity}x'),
                    ),
                    // Button to increase quantity
                    InkWell(
                      onTap: () => cartProvider.addItem(product),
                      child: const Icon(Icons.add_circle_outline, size: 20),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}