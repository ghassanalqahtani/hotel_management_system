import 'dart:convert';
import 'package:http/http.dart' as http;
import 'conncetion.dart';

class BookingService {
  Future<List<dynamic>> getBookings(int userId) async {
    final String url = '${ConnectionString.baseUrl}/api/Booking/user/$userId';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data;
      } else {
        throw Exception('Failed to load bookings. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching bookings: $e');
    }
  }

  Future<void> cancelBooking(int userId, int bookingId) async {
    final String url = '${ConnectionString.baseUrl}/api/Booking/cancel';

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
        throw Exception('Failed to cancel booking. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error cancelling booking: $e');
    }
  }
}
