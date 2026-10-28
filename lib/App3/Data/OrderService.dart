import 'dart:convert';
import 'package:http/http.dart' as http;
import 'connection.dart';

class OrderService {
  Future<int> makeOrder(int userId) async {
    final response = await http.post(
      Uri.parse('${ConnectionString.orders}/make'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'userId': userId}),
    );

    final body = json.decode(response.body);

    if (response.statusCode == 200) {
      return body['orderId'] as int;
    }

    throw Exception(body['message'] ?? body['error'] ?? 'Failed to create order');
  }

  Future<List<dynamic>> getOrders(int userId) async {
    final response = await http.get(
      Uri.parse('${ConnectionString.orders}/user/$userId'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body) as List<dynamic>;
    }

    throw Exception('Failed to load orders. Status code: ${response.statusCode}');
  }
}