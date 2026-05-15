import 'package:flutter/material.dart';
import '../models/mission.dart';
import '../models/candidature.dart';
import '../services/api_service.dart';

class MissionProvider extends ChangeNotifier {
  List<Mission> _missions = [];
  Mission? _selectedMission;
  List<Candidature> _candidatures = [];
  bool _loading = false;
  String? _error;

  List<Mission> get missions => _missions;
  Mission? get selectedMission => _selectedMission;
  List<Candidature> get candidatures => _candidatures;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> fetchMissions({String? search, String? statut, String? categorie}) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      String path = 'missions';
      final params = <String>[];
      if (search != null && search.isNotEmpty) params.add('search=$search');
      if (statut != null && statut.isNotEmpty) params.add('statut=$statut');
      if (categorie != null && categorie.isNotEmpty) params.add('categorie=$categorie');
      if (params.isNotEmpty) path += '?${params.join('&')}';

      final data = await ApiService.get(path);
      _missions = (data as List).map((e) => Mission.fromJson(e)).toList();
    } on ApiException catch (e) {
      _error = e.message;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<Mission?> fetchMissionDetail(int id) async {
    try {
      final data = await ApiService.get('missions/$id');
      _selectedMission = Mission.fromJson(data);
      notifyListeners();
      return _selectedMission;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return null;
    }
  }

  Future<bool> createMission(Map<String, dynamic> missionData) async {
    _loading = true;
    notifyListeners();
    try {
      final data = await ApiService.post('missions', missionData);
      final mission = Mission.fromJson(data);
      _missions.insert(0, mission);
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

  Future<bool> applyToMission(int missionId, Map<String, dynamic> data) async {
    try {
      await ApiService.post('apply', {'mission': missionId, ...data});
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchCandidatures(int missionId) async {
    try {
      final data = await ApiService.get('mission/$missionId/applications');
      _candidatures = (data as List).map((e) => Candidature.fromJson(e)).toList();
      notifyListeners();
    } catch (_) {}
  }

  Future<Map<String, dynamic>?> fetchDashboard() async {
    try {
      return await ApiService.get('dashboard');
    } catch (_) {
      return null;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
