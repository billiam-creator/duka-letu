import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:duka_letu/models/product.dart';
import 'package:duka_letu/providers/cart_provider.dart';
// Note: You must also ensure product.dart has the 'category' field for this to filter correctly

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> categories = ['All', 'Electronics', 'Apparel', 'Home & Kitchen', 'Books'];
  String _selectedCategory = 'All';
  String _searchQuery = ''; // State for the search query

  // Dummy widget for a product tile - replace with your actual widget later
  Widget _buildProductTile(BuildContext context, Product product) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    return Card(
      elevation: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Center(
              child: Image.network(
                product.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported, size: 50),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              product.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.add_shopping_cart, size: 20),
                  onPressed: () {
                    cartProvider.addItem(product);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${product.name} added to cart!')),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Duka Letu'),
        // NOTE: The Cart icon is now in the MainScreen's BottomNavigationBar, so no need here.
        automaticallyImplyLeading: false, 
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
            ),
          ),
        ),
      ),
      
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Horizontal Category List
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = category == _selectedCategory;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    selectedColor: Theme.of(context).colorScheme.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),

          // 2. Product Grid (Filtered)
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('products').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No products found. (Add them via Admin Dashboard)'));
                }

                // Map, Filter, and Search Products
                final allProducts = snapshot.data!.docs.map((doc) {
                  // Ensure Product.fromFirestore handles all fields, including 'category'
                  return Product.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
                }).toList();

                final filteredProducts = allProducts.where((product) {
                  // Category Filter
                  final categoryMatch = (_selectedCategory == 'All') || (product.category == _selectedCategory);
                  
                  // Search Filter
                  final searchMatch = _searchQuery.isEmpty || 
                                      product.name.toLowerCase().contains(_searchQuery) ||
                                      product.description.toLowerCase().contains(_searchQuery);

                  return categoryMatch && searchMatch;
                }).toList();


                if (filteredProducts.isEmpty) {
                  return const Center(child: Text('No products match your criteria.'));
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(10),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7, // Adjust ratio to fit card content
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    return _buildProductTile(context, filteredProducts[index]);
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