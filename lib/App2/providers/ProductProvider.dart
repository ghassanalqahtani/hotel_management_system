import 'package:flutter/material.dart';
import '../../Hotel/Data/ProductService.dart';

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

  void clear() {
    products = [];
    loaded = false;
    error = null;
    notifyListeners();
  }
}