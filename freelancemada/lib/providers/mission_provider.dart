import 'package:flutter/material.dart';
import '../models/mission.dart';
import '../services/api_service.dart';

class MissionProvider extends ChangeNotifier {
  List<Mission> _missions = [];
  bool _loading = false;
  String? _error;
  int _count = 0;
  int _currentPage = 1;
  bool _hasMore = true;

  List<Mission> get missions => _missions;
  bool get loading => _loading;
  String? get error => _error;
  int get count => _count;
  bool get hasMore => _hasMore;

  Future<void> loadMissions({
    String? search,
    String? statut,
    String? categorie,
    bool mine = false,
    bool reset = true,
  }) async {
    if (reset) {
      _currentPage = 1;
      _hasMore = true;
      _missions = [];
    }
    if (!_hasMore) return;
    _loading = true;
    _error = null;
    if (reset) notifyListeners();

    try {
      final data = await ApiService.getMissions(
        search: search,
        statut: statut,
        categorie: categorie,
        mine: mine,
        page: _currentPage,
      );
      final List<dynamic> results = data['results'] ?? data;
      final missions = results.map((m) => Mission.fromJson(m)).toList();
      _count = data['count'] ?? missions.length;
      if (reset) {
        _missions = missions;
      } else {
        _missions.addAll(missions);
      }
      _hasMore = data['next'] != null;
      _currentPage++;
    } catch (_) {
      _error = 'Erreur lors du chargement des missions.';
    }
    _loading = false;
    notifyListeners();
  }

  Future<Mission?> getMission(int id) async {
    try {
      final data = await ApiService.getMission(id);
      return Mission.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  Future<bool> createMission(Map<String, dynamic> data) async {
    try {
      final result = await ApiService.createMission(data);
      if (result['id'] != null) {
        _missions.insert(0, Mission.fromJson(result));
        notifyListeners();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateMission(int id, Map<String, dynamic> data) async {
    try {
      final result = await ApiService.updateMission(id, data);
      final idx = _missions.indexWhere((m) => m.id == id);
      if (idx != -1) _missions[idx] = Mission.fromJson(result);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteMission(int id) async {
    final ok = await ApiService.deleteMission(id);
    if (ok) {
      _missions.removeWhere((m) => m.id == id);
      notifyListeners();
    }
    return ok;
  }
}
