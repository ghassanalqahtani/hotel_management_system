import 'dart:convert';
import 'package:http/http.dart' as http;

import 'connection.dart';


class ProductService {
  Future<List<dynamic>> getProducts() async {
    final String url = ConnectionString.products;
    print('URL: $url');

    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 15));

      print('STATUS: ${response.statusCode}');

      if (response.statusCode == 200) {
        return json.decode(response.body) as List<dynamic>;
      } else {
        throw Exception(
            'Failed to load products. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching products: $e');
    }
  }
}