import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:duka_letu/models/product.dart';
import 'package:duka_letu/providers/auth_provider.dart';
import 'package:duka_letu/screens/add_edit_product_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  static const routeName = '/admin-dashboard';

  const AdminDashboardScreen({super.key});

  Future<void> _deleteProduct(BuildContext context, String productId) async {
    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product deleted successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting product: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final adminEmail = authProvider.user?.email ?? 'Admin';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AddEditProductScreen(),
                ),
              );
            },
            tooltip: 'Add New Product',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.logout(); // fixed
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Welcome back, $adminEmail',
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Manage Products (Swipe left to Delete):',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('products')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child:
                        Text('Error loading products: ${snapshot.error}'),
                  );
                }

                if (!snapshot.hasData ||
                    snapshot.data!.docs.isEmpty) {
                  return const Center(
                      child: Text('No products available. Add one!'));
                }

                final products = snapshot.data!.docs.map((doc) {
                  return Product.fromFirestore(
                      doc.data() as Map<String, dynamic>, doc.id);
                }).toList();

                return ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return Dismissible(
                      key: ValueKey(product.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete,
                            color: Colors.white, size: 30),
                      ),
                      confirmDismiss: (direction) {
                        return showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Are you sure?'),
                            content: const Text(
                                'Do you want to remove this product from the store?'),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(ctx).pop(false),
                                child: const Text('No'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(ctx).pop(true),
                                child: const Text('Yes'),
                              ),
                            ],
                          ),
                        );
                      },
                      onDismissed: (direction) {
                        _deleteProduct(context, product.id);
                      },
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage:
                              NetworkImage(product.imageUrl),
                        ),
                        title: Text(product.name),
                        subtitle: Text(
                          '\$${product.price.toStringAsFixed(2)} | Qty: ${product.quantity}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    AddEditProductScreen(product: product),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
