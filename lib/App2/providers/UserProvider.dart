import 'package:flutter/material.dart';
import '../Data/UserService.dart';

class UserProvider extends ChangeNotifier {
  final UserService userService = UserService();

  Map<String, dynamic>? user;

  bool isLoading = false;

  String? error;

  Future<bool> login(String username, String password) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      user = await userService.login(username, password);

      if (user == null) {
        error = 'Invalid username or password';
        return false;
      }

      return true;
    } catch (e) {
      error = 'Failed to connect to server';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(
      String name,
      String email,
      String username,
      String password,
      ) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final created = await userService.register(name, email, username, password);

      if (!created) {
        error = 'Username already exists';
        return false;
      }

      user = await userService.login(username, password);

      if (user == null) {
        error = 'Account created, but login failed';
        return false;
      }

      return true;
    } catch (e) {
      error = 'Failed to connect to server';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  String get username => user?['username']?.toString() ?? '';

  String get email => user?['email']?.toString() ?? '';

  int get userId => (user?['userId'] as num?)?.toInt() ?? 0;

  bool get isLoggedIn => user != null;

  void logout() {
    user = null;
    error = null;
    notifyListeners();
  }
}