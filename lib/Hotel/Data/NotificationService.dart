import 'dart:convert';
import 'package:http/http.dart' as http;
import 'conncetion.dart';

class NotificationService {
  Future<List<dynamic>> getNotifications(int userId) async {
    final String url = '${ConnectionString.notifications}/user/$userId';
    print('GET URL: $url');

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        print('BODY: ${response.body}');
        return json.decode(response.body) as List<dynamic>;
      } else {
        throw Exception(
            'Failed to load notifications. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching notifications: $e');
    }
  }

  Future<int> getUnreadCount(int userId) async {
    final String url = '${ConnectionString.notifications}/unread-count/$userId';
    print('GET URL: $url');

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return json.decode(response.body)['count'] as int;
      } else {
        throw Exception(
            'Failed to load unread count. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching unread count: $e');
    }
  }

  Future<void> markAllAsRead(int userId) async {
    final String url = '${ConnectionString.notifications}/mark-all-read';
    print('POST URL: $url');

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'userId': userId}),
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to mark as read. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error marking notifications as read: $e');
    }
  }
}