// lib/providers/user_provider.dart
import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  String? _token;
  int? _userId;
  String? _nombre;

  String? get token => _token;
  int? get userId => _userId;
  String? get nombre => _nombre;

  void setUser(
      {required String token, required int userId, required String nombre}) {
    _token = token;
    _userId = userId;
    _nombre = nombre;
    notifyListeners();
  }

  void clearUser() {
    _token = null;
    _userId = null;
    _nombre = null;
    notifyListeners();
  }

  bool get isLoggedIn => _token != null;
}
