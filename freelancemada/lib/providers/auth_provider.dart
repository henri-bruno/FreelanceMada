import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _loading = false;
  String? _error;

  User? get user => _user;
  bool get loading => _loading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  Future<bool> checkAuth() async {
    final token = await ApiService.getToken();
    if (token == null) return false;
    try {
      final data = await ApiService.get('profile');
      _user = User.fromJson(data);
      notifyListeners();
      return true;
    } catch (_) {
      await ApiService.clearTokens();
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final data = await ApiService.post('login', {'email': email, 'password': password}, auth: false);
      await ApiService.saveTokens(data['access'], data['refresh']);
      _user = User.fromJson(data['user']);
      _loading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String nom,
    required String email,
    required String password,
    required String role,
    String telephone = '',
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final data = await ApiService.post('register', {
        'nom': nom,
        'email': email,
        'password': password,
        'role': role,
        'telephone': telephone,
      }, auth: false);
      await ApiService.saveTokens(data['access'], data['refresh']);
      _user = User.fromJson(data['user']);
      _loading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> loadProfile() async {
    try {
      final data = await ApiService.get('profile');
      _user = User.fromJson(data);
      notifyListeners();
    } catch (_) {}
  }

  Future<bool> updateProfile(Map<String, dynamic> profileData) async {
    _loading = true;
    notifyListeners();
    try {
      final data = await ApiService.put('profile/update', profileData);
      _user = User.fromJson(data);
      _loading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await ApiService.clearTokens();
    _user = null;
    notifyListeners();
  }
}
