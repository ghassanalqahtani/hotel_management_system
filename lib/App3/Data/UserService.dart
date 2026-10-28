import 'dart:convert';
import 'package:http/http.dart' as http;
import 'connection.dart';

class UserService {
  Future<Map<String, dynamic>?> login(String username, String password) async {
    final response = await http.post(
      Uri.parse(ConnectionString.login),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    print('LOGIN ${response.statusCode}: ${response.body}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    if (response.statusCode == 400 || response.statusCode == 401) {
      return null;
    }

    throw Exception('Login failed: ${response.statusCode}');
  }

  Future<bool> register(
      String name,
      String email,
      String username,
      String password,
      ) async {
    final response = await http.post(
      Uri.parse(ConnectionString.register),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'username': username,
        'password': password,
      }),
    );

    print('REGISTER ${response.statusCode}: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    }

    if (response.statusCode == 400 || response.statusCode == 409) {
      return false;
    }

    throw Exception('Register failed: ${response.statusCode}');
  }
}