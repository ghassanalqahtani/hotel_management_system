import 'dart:convert';
import 'package:http/http.dart' as http;
import 'conncetion.dart';

class OrderService {
  // يحوّل سلة المستخدم إلى طلب، ويرجّع رقم الطلب
  Future<int> makeOrder(int userId) async {
    final String url = '${ConnectionString.orders}/make';
    print('POST URL: $url');

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'userId': userId}),
      );

      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        return body['orderId'] as int;
      } else {
        // الـ API يرجّع الرسالة في message أو error
        throw Exception(body['message'] ?? body['error'] ?? 'Failed to create order');
      }
    } catch (e) {
      throw Exception('Error creating order: $e');
    }
  }

  Future<List<dynamic>> getOrders(int userId) async {
    final String url = '${ConnectionString.orders}/user/$userId';
    print('GET URL: $url');

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        print('BODY: ${response.body}');
        return json.decode(response.body) as List<dynamic>;
      } else {
        throw Exception(
            'Failed to load orders. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching orders: $e');
    }
  }
}