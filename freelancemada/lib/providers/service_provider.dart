import 'package:flutter/material.dart';
import '../models/service.dart';
import '../services/api_service.dart';

class ServiceProvider extends ChangeNotifier {
  List<Service> _services = [];
  bool _loading = false;
  String? _error;
  bool _hasMore = true;
  int _currentPage = 1;

  List<Service> get services => _services;
  bool get loading => _loading;
  String? get error => _error;
  bool get hasMore => _hasMore;

  Future<void> loadServices({
    String? search,
    String? categorie,
    bool mine = false,
    bool reset = true,
  }) async {
    if (reset) {
      _currentPage = 1;
      _hasMore = true;
      _services = [];
    }
    if (!_hasMore) return;
    _loading = true;
    _error = null;
    if (reset) notifyListeners();

    try {
      final data = await ApiService.getServices(
        search: search,
        categorie: categorie,
        mine: mine,
        page: _currentPage,
      );
      final List<dynamic> results = data['results'] ?? data;
      final services = results.map((s) => Service.fromJson(s)).toList();
      if (reset) {
        _services = services;
      } else {
        _services.addAll(services);
      }
      _hasMore = data['next'] != null;
      _currentPage++;
    } catch (_) {
      _error = 'Erreur lors du chargement des services.';
    }
    _loading = false;
    notifyListeners();
  }

  Future<Service?> getService(int id) async {
    try {
      final data = await ApiService.getService(id);
      return Service.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  Future<bool> createService(Map<String, dynamic> serviceData, Map<String, dynamic> packageData) async {
    try {
      final result = await ApiService.createService(serviceData);
      if (result['id'] != null) {
        final serviceId = result['id'];
        await ApiService.createServicePackage(serviceId, packageData);
        final updatedServiceData = await ApiService.getService(serviceId);
        _services.insert(0, Service.fromJson(updatedServiceData));
        notifyListeners();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}
