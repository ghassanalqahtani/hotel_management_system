import 'dart:convert';
import 'package:http/http.dart' as http;

class ProductService {

  Future<List<dynamic>> getProducts() async {

    final response = await http.get(
      Uri.parse('https://0p81xswl-7127.uks1.devtunnels.ms/api/Products'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load products');
    }
  }
}