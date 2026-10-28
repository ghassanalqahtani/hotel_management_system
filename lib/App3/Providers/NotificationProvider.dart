import 'package:flutter/material.dart';
import '../Data/NotificationService.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService notificationService = NotificationService();

  List<dynamic> notifications = [];

  int unreadCount = 0;

  bool isLoading = false;

  String? error;

  Future<void> loadNotifications(int userId) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      notifications = await notificationService.getNotifications(userId);
    } catch (e) {
      error = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUnreadCount(int userId) async {
    try {
      unreadCount = await notificationService.getUnreadCount(userId);
    } catch (e) {
      unreadCount = 0;
    }
    notifyListeners();
  }

  Future<void> markAllAsRead(int userId) async {
    try {
      await notificationService.markAllAsRead(userId);
      unreadCount = 0;
    } catch (e) {
      error = e.toString().replaceAll('Exception: ', '');
    }
    notifyListeners();
  }

  void clear() {
    notifications = [];
    unreadCount = 0;
    error = null;
    isLoading = false;
    notifyListeners();
  }
}