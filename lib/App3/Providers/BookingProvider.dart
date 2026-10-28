import 'package:flutter/material.dart';
import '../Data/BookingService.dart';

class BookingProvider extends ChangeNotifier {
  final BookingService bookingService = BookingService();

  List<dynamic> bookings = [];

  List<dynamic> availableRooms = [];

  bool isLoading = false;

  bool isSaving = false;

  String? error;

  double get total => bookings.fold<double>(
    0,
        (sum, item) => sum + ((item['totalPrice'] ?? 0) as num).toDouble(),
  );

  String _clean(Object e) => e.toString().replaceAll('Exception: ', '');

  Future<void> loadBookings(int userId) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      bookings = await bookingService.getBookings(userId);
    } catch (e) {
      error = _clean(e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAvailableRooms() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      availableRooms = await bookingService.getAvailableRooms();
    } catch (e) {
      error = _clean(e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createBooking(int userId, int roomId, int nights) async {
    isSaving = true;
    error = null;
    notifyListeners();

    try {
      await bookingService.createBooking(userId, roomId, nights);
      await loadBookings(userId);
      return true;
    } catch (e) {
      error = _clean(e);
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> cancelBooking(int userId, int bookingId) async {
    error = null;

    try {
      await bookingService.cancelBooking(userId, bookingId);
      await loadBookings(userId);
      return true;
    } catch (e) {
      error = _clean(e);
      notifyListeners();
      return false;
    }
  }

  void clear() {
    bookings = [];
    availableRooms = [];
    error = null;
    isLoading = false;
    isSaving = false;
    notifyListeners();
  }
}