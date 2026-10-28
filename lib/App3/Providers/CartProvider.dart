import 'package:flutter/material.dart';
import '../Data/CartService.dart';
import '../Data/OrderService.dart';

class CartProvider extends ChangeNotifier {
  final CartService cartService = CartService();
  final OrderService orderService = OrderService();

  List<dynamic> items = [];

  bool isLoading = false;

  bool isPlacing = false;

  String? error;

  double get total => items.fold<double>(
    0,
        (sum, item) => sum + ((item['totalPrice'] ?? 0) as num).toDouble(),
  );

  String _clean(Object e) => e.toString().replaceAll('Exception: ', '');

  Future<void> loadCart(int userId) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      items = await cartService.getCart(userId);
    } catch (e) {
      error = _clean(e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addToCart(int userId, int productId, int quantity) async {
    error = null;

    try {
      for (var i = 0; i < quantity; i++) {
        await cartService.addToCart(userId, productId);
      }
      return true;
    } catch (e) {
      error = _clean(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> removeItem(int userId, int productId) async {
    error = null;

    try {
      await cartService.removeFromCart(userId, productId);
      await loadCart(userId);
      return true;
    } catch (e) {
      error = _clean(e);
      notifyListeners();
      return false;
    }
  }

  Future<int> placeOrder(int userId) async {
    isPlacing = true;
    error = null;
    notifyListeners();

    try {
      final orderId = await orderService.makeOrder(userId);
      items = [];
      return orderId;
    } catch (e) {
      error = _clean(e);
      return 0;
    } finally {
      isPlacing = false;
      notifyListeners();
    }
  }

  void clear() {
    items = [];
    error = null;
    isLoading = false;
    isPlacing = false;
    notifyListeners();
  }
}