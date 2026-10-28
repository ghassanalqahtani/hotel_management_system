import 'package:flutter/material.dart';
import '../Data/OrderService.dart';

class OrderProvider extends ChangeNotifier {
  final OrderService orderService = OrderService();

  List<dynamic> orders = [];

  bool isLoading = false;

  String? error;

  Future<void> loadOrders(int userId) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      orders = await orderService.getOrders(userId);
    } catch (e) {
      error = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    orders = [];
    error = null;
    isLoading = false;
    notifyListeners();
  }
}