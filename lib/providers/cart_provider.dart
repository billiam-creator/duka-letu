// lib/providers/cart_provider.dart

import 'package:flutter/material.dart';
import 'package:duka_letu/models/product.dart';
import 'package:duka_letu/models/cart_item.dart';

class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};

  // All these getters and methods are required
  List<CartItem> get cartItems => _items.values.toList();
  int get itemCount => _items.values.fold(0, (sum, item) => sum + item.quantity);
  double get totalPrice => _items.values.fold(0.0, (sum, item) => sum + item.totalPrice);
  Map<String, CartItem> get items => _items;

  void addToCart(Product product) {
    if (_items.containsKey(product.id)) {
      _items.update(
        product.id,
        (existingItem) => CartItem(
          product: existingItem.product,
          quantity: existingItem.quantity + 1,
        ),
      );
    } else {
      _items.putIfAbsent(
        product.id,
        () => CartItem(product: product),
      );
    }
    notifyListeners();
  }

  void removeFromCart(CartItem item) {
    _items.remove(item.product.id);
    notifyListeners();
  }

  void increaseQuantity(CartItem item) {
    _items.update(
      item.product.id,
      (existingItem) => CartItem(
        product: existingItem.product,
        quantity: existingItem.quantity + 1,
      ),
    );
    notifyListeners();
  }

  void decreaseQuantity(CartItem item) {
    if (item.quantity > 1) {
      _items.update(
        item.product.id,
        (existingItem) => CartItem(
          product: existingItem.product,
          quantity: existingItem.quantity - 1,
        ),
      );
    } else {
      _items.remove(item.product.id);
    }
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}