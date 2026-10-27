import 'dart:convert';
import 'package:http/http.dart' as http;
import 'conncetion.dart';

class BookingService {
  Future<List<dynamic>> getBookings(int userId) async {
    final String url = '${ConnectionString.booking}/user/$userId';
    print('GET URL: $url');

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        print('BODY: ${response.body}');
        return json.decode(response.body) as List<dynamic>;
      } else {
        throw Exception(
            'Failed to load bookings. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching bookings: $e');
    }
  }

  Future<List<dynamic>> getAvailableRooms() async {
    final String url = '${ConnectionString.rooms}/available';
    print('GET URL: $url');

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return json.decode(response.body) as List<dynamic>;
      } else {
        throw Exception(
            'Failed to load rooms. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching rooms: $e');
    }
  }

  Future<void> createBooking(int userId, int roomId, int nights) async {
    final String url = '${ConnectionString.booking}/create';
    print('POST URL: $url');

    try {
      final response = await http.post(
        Uri.parse(url),
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
    } catch (e) {
      throw Exception('$e'.replaceAll('Exception: ', ''));
    }
  }

  Future<void> cancelBooking(int userId, int bookingId) async {
    final String url = '${ConnectionString.booking}/cancel';
    print('POST URL: $url');

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': userId,
          'bookingId': bookingId,
        }),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception(
            'Failed to cancel booking. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error cancelling booking: $e');
    }
  }
}