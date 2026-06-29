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
      final data = await ApiService.getMe();
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
      final data = await ApiService.login(email, password);
      if (data['access'] == null) {
        _error = _extractError(data);
        _loading = false;
        notifyListeners();
        return false;
      }
      await ApiService.saveTokens(data['access'], data['refresh']);
      _user = User.fromJson(data['user']);
      _loading = false;
      notifyListeners();
      return true;
    } catch (_) {
      _error = 'Erreur réseau. Vérifiez votre connexion.';
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String nom,
    String prenom = '',
    required String email,
    required String password,
    required String role,
    String telephone = '',
    String ville = '',
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final data = await ApiService.register({
        'nom': nom,
        'prenom': prenom,
        'email': email,
        'password': password,
        'role': role,
        'telephone': telephone,
        'ville': ville,
      });
      if (data['access'] == null) {
        _error = _extractError(data);
        _loading = false;
        notifyListeners();
        return false;
      }
      await ApiService.saveTokens(data['access'], data['refresh']);
      _user = User.fromJson(data['user']);
      _loading = false;
      notifyListeners();
      return true;
    } catch (_) {
      _error = 'Erreur réseau. Vérifiez votre connexion.';
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> profileData) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final data = await ApiService.updateMe(profileData);
      _user = User.fromJson(data);
      _loading = false;
      notifyListeners();
      return true;
    } catch (_) {
      _error = 'Erreur lors de la mise à jour.';
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

  void clearError() {
    _error = null;
    notifyListeners();
  }

  String _extractError(Map<String, dynamic> data) {
    for (final key in data.keys) {
      final val = data[key];
      if (val is List && val.isNotEmpty) return val.first.toString();
      if (val is String) return val;
    }
    return 'Une erreur est survenue.';
  }
}
