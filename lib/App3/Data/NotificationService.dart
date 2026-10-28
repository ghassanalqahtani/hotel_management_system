import 'dart:convert';
import 'package:http/http.dart' as http;
import 'connection.dart';

class NotificationService {
  Future<List<dynamic>> getNotifications(int userId) async {
    final response = await http.get(
      Uri.parse('${ConnectionString.notifications}/user/$userId'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body) as List<dynamic>;
    }

    throw Exception(
        'Failed to load notifications. Status code: ${response.statusCode}');
  }

  Future<int> getUnreadCount(int userId) async {
    final response = await http.get(
      Uri.parse('${ConnectionString.notifications}/unread-count/$userId'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body)['count'] as int;
    }

    throw Exception(
        'Failed to load unread count. Status code: ${response.statusCode}');
  }

  Future<void> markAllAsRead(int userId) async {
    final response = await http.post(
      Uri.parse('${ConnectionString.notifications}/mark-all-read'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'userId': userId}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to mark as read. Status code: ${response.statusCode}');
    }
  }
}