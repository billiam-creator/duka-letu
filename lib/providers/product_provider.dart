import 'package:flutter/foundation.dart';
import '../models/product.dart';

class ProductProvider with ChangeNotifier {
  final List<Product> _items = [];

  List<Product> get items => [..._items];

  void addProduct(Product product) {
    _items.add(product);
    notifyListeners();
  }
}
