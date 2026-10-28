import 'package:flutter/material.dart';
import '../Data/ProductService.dart';

class ProductProvider extends ChangeNotifier {
  final ProductService productService = ProductService();

  List<dynamic> products = [];

  bool isLoading = false;

  String? error;

  bool loaded = false;

  Future<void> loadProducts({bool force = false}) async {
    if (loaded && !force) return;

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      products = await productService.getProducts();
      loaded = true;
    } catch (e) {
      error = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  dynamic getById(int id) {
    for (final p in products) {
      if (p['id'] == id) return p;
    }
    return null;
  }

  void clear() {
    products = [];
    loaded = false;
    error = null;
    notifyListeners();
  }
}