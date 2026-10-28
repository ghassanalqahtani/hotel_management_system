import 'dart:convert';
import 'package:http/http.dart' as http;
import 'connection.dart';

class BookingService {
  Future<List<dynamic>> getBookings(int userId) async {
    final response = await http.get(
      Uri.parse('${ConnectionString.booking}/user/$userId'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body) as List<dynamic>;
    }

    throw Exception('Failed to load bookings. Status code: ${response.statusCode}');
  } 

  Future<List<dynamic>> getAvailableRooms() async {
    final response = await http.get(
      Uri.parse('${ConnectionString.rooms}/available'),
    );
       
    if (response.statusCode == 200) {
      return json.decode(response.body) as List<dynamic>;
    }

    throw Exception('Failed to load rooms. Status code: ${response.statusCode}');
  }

  Future<void> createBooking(int userId, int roomId, int nights) async {
    final response = await http.post(
      Uri.parse('${ConnectionString.booking}/create'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'userId': userId,
        'roomsId': roomId,
        'numberOfNights': nights,
      }),
    );

    if (response.statusCode != 200) {
      String message = 'Failed to create booking';
      try {
        final body = json.decode(response.body);
        message = body['error'] ?? body['message'] ?? message;
      } catch (_) {}
      throw Exception(message);
    }
  }

  Future<void> cancelBooking(int userId, int bookingId) async {
    final response = await http.post(
      Uri.parse('${ConnectionString.booking}/cancel'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'userId': userId,
        'bookingId': bookingId,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to cancel booking. Status code: ${response.statusCode}');
    }
  }
}