import 'dart:convert';
import 'package:http/http.dart' as http;
import 'connection.dart';

class CartService {
  Future<List<dynamic>> getCart(int userId) async {
    final response = await http.get(
      Uri.parse('${ConnectionString.cart}/$userId'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    }

    throw Exception('Failed to load cart');
  }

  Future<void> addToCart(int userId, int productId) async {
    final response = await http.post(
      Uri.parse(ConnectionString.cart),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'productId': productId,
        'quantity': 1,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to add product');
    }
  }

  Future<void> removeFromCart(int userId, int productId) async {
    final response = await http.delete(
      Uri.parse('${ConnectionString.cart}/$userId/$productId'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to remove product');
    }
  }
}