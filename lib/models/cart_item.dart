// lib/models/cart_item.dart

import 'package:duka_letu/models/product.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get totalPrice => product.price * quantity;

  // ADDED THESE GETTERS
  String get imageUrl => product.imageUrl;
  String get name => product.name;
  double get price => product.price;
}