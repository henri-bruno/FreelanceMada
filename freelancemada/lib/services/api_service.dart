import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';

class ApiService {
  static const String _tokenKey = 'access_token';
  static const String _refreshKey = 'refresh_token';

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> saveTokens(String access, String refresh) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, access);
    await prefs.setString(_refreshKey, refresh);
  }

  static Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_refreshKey);
  }

  static Future<Map<String, String>> _headers({bool auth = true}) async {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (auth) {
      final token = await getToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // ── Auth ────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await http.post(
      Uri.parse('${AppConstants.baseUrl}/auth/login/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
    final res = await http.post(
      Uri.parse('${AppConstants.baseUrl}/auth/register/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    return jsonDecode(res.body);
  }

  static Future<void> logout(String refreshToken) async {
    final headers = await _headers();
    await http.post(
      Uri.parse('${AppConstants.baseUrl}/auth/logout/'),
      headers: headers,
      body: jsonEncode({'refresh': refreshToken}),
    );
    await clearTokens();
  }

  // ── Profil ──────────────────────────────────────────────────
  static Future<Map<String, dynamic>> getMe() async {
    final res = await http.get(
      Uri.parse('${AppConstants.baseUrl}/me/'),
      headers: await _headers(),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> updateMe(Map<String, dynamic> data) async {
    final res = await http.patch(
      Uri.parse('${AppConstants.baseUrl}/me/'),
      headers: await _headers(),
      body: jsonEncode(data),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> getUser(int id) async {
    final res = await http.get(
      Uri.parse('${AppConstants.baseUrl}/users/$id/'),
      headers: await _headers(),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> getFreelances({
    String? search,
    String? disponibilite,
    String? competence,
    double? tarifMax,
    int page = 1,
  }) async {
    final params = <String, String>{'page': page.toString()};
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (disponibilite != null) params['disponibilite'] = disponibilite;
    if (competence != null) params['competence'] = competence;
    if (tarifMax != null) params['tarif_max'] = tarifMax.toString();

    final res = await http.get(
      Uri.parse('${AppConstants.baseUrl}/freelances/').replace(queryParameters: params),
      headers: await _headers(),
    );
    return jsonDecode(res.body);
  }

  // ── Missions ────────────────────────────────────────────────
  static Future<Map<String, dynamic>> getMissions({
    String? search,
    String? statut,
    String? categorie,
    bool mine = false,
    int page = 1,
  }) async {
    final params = <String, String>{'page': page.toString()};
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (statut != null) params['statut'] = statut;
    if (categorie != null) params['categorie'] = categorie;
    if (mine) params['mine'] = '1';

    final res = await http.get(
      Uri.parse('${AppConstants.baseUrl}/missions/').replace(queryParameters: params),
      headers: await _headers(),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> getMission(int id) async {
    final res = await http.get(
      Uri.parse('${AppConstants.baseUrl}/missions/$id/'),
      headers: await _headers(),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> createMission(Map<String, dynamic> data) async {
    final res = await http.post(
      Uri.parse('${AppConstants.baseUrl}/missions/'),
      headers: await _headers(),
      body: jsonEncode(data),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> updateMission(int id, Map<String, dynamic> data) async {
    final res = await http.patch(
      Uri.parse('${AppConstants.baseUrl}/missions/$id/'),
      headers: await _headers(),
      body: jsonEncode(data),
    );
    return jsonDecode(res.body);
  }

  static Future<bool> deleteMission(int id) async {
    final res = await http.delete(
      Uri.parse('${AppConstants.baseUrl}/missions/$id/'),
      headers: await _headers(),
    );
    return res.statusCode == 204;
  }

  // ── Services ────────────────────────────────────────────────
  static Future<Map<String, dynamic>> getServices({
    String? search,
    String? categorie,
    bool mine = false,
    int page = 1,
  }) async {
    final params = <String, String>{'page': page.toString()};
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (categorie != null) params['categorie'] = categorie;
    if (mine) params['mine'] = '1';

    final res = await http.get(
      Uri.parse('${AppConstants.baseUrl}/services/').replace(queryParameters: params),
      headers: await _headers(),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> getService(int id) async {
    final res = await http.get(
      Uri.parse('${AppConstants.baseUrl}/services/$id/'),
      headers: await _headers(),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> createService(Map<String, dynamic> data) async {
    final res = await http.post(
      Uri.parse('${AppConstants.baseUrl}/services/'),
      headers: await _headers(),
      body: jsonEncode(data),
    );
    return jsonDecode(res.body);
  }

  // ── Candidatures ────────────────────────────────────────────
  static Future<Map<String, dynamic>> getCandidatures({int? missionId}) async {
    final params = <String, String>{};
    if (missionId != null) params['mission_id'] = missionId.toString();
    final res = await http.get(
      Uri.parse('${AppConstants.baseUrl}/candidatures/').replace(queryParameters: params),
      headers: await _headers(),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> createCandidature(Map<String, dynamic> data) async {
    final res = await http.post(
      Uri.parse('${AppConstants.baseUrl}/candidatures/'),
      headers: await _headers(),
      body: jsonEncode(data),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> updateCandidature(int id, Map<String, dynamic> data) async {
    final res = await http.patch(
      Uri.parse('${AppConstants.baseUrl}/candidatures/$id/'),
      headers: await _headers(),
      body: jsonEncode(data),
    );
    return jsonDecode(res.body);
  }

  // ── Contrats ────────────────────────────────────────────────
  static Future<List<dynamic>> getContrats() async {
    final res = await http.get(
      Uri.parse('${AppConstants.baseUrl}/contrats/'),
      headers: await _headers(),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> getContrat(int id) async {
    final res = await http.get(
      Uri.parse('${AppConstants.baseUrl}/contrats/$id/'),
      headers: await _headers(),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> updateContrat(int id, Map<String, dynamic> data) async {
    final res = await http.patch(
      Uri.parse('${AppConstants.baseUrl}/contrats/$id/'),
      headers: await _headers(),
      body: jsonEncode(data),
    );
    return jsonDecode(res.body);
  }

  // ── Messages ────────────────────────────────────────────────
  static Future<List<dynamic>> getConversations() async {
    final res = await http.get(
      Uri.parse('${AppConstants.baseUrl}/conversations/'),
      headers: await _headers(),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> getMessages(int userId, {int page = 1}) async {
    final res = await http.get(
      Uri.parse('${AppConstants.baseUrl}/messages/$userId/?page=$page'),
      headers: await _headers(),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> sendMessage(Map<String, dynamic> data) async {
    final res = await http.post(
      Uri.parse('${AppConstants.baseUrl}/messages/${data['receiver']}/'),
      headers: await _headers(),
      body: jsonEncode(data),
    );
    return jsonDecode(res.body);
  }

  // ── Paiements ────────────────────────────────────────────────
  static Future<List<dynamic>> getPaiements() async {
    final res = await http.get(
      Uri.parse('${AppConstants.baseUrl}/paiements/'),
      headers: await _headers(),
    );
    return jsonDecode(res.body);
  }

  // ── Avis ────────────────────────────────────────────────────
  static Future<List<dynamic>> getAvis({int? cibleId, int? serviceId}) async {
    final params = <String, String>{};
    if (cibleId != null) params['cible_id'] = cibleId.toString();
    if (serviceId != null) params['service_id'] = serviceId.toString();
    final res = await http.get(
      Uri.parse('${AppConstants.baseUrl}/avis/').replace(queryParameters: params),
      headers: await _headers(),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> createAvis(Map<String, dynamic> data) async {
    final res = await http.post(
      Uri.parse('${AppConstants.baseUrl}/avis/'),
      headers: await _headers(),
      body: jsonEncode(data),
    );
    return jsonDecode(res.body);
  }

  // ── Notifications ─────────────────────────────────────────
  static Future<Map<String, dynamic>> getNotifications({int page = 1}) async {
    final res = await http.get(
      Uri.parse('${AppConstants.baseUrl}/notifications/?page=$page'),
      headers: await _headers(),
    );
    return jsonDecode(res.body);
  }

  static Future<void> markNotificationRead(int? id) async {
    final url = id != null
        ? '${AppConstants.baseUrl}/notifications/$id/read/'
        : '${AppConstants.baseUrl}/notifications/read/';
    await http.post(Uri.parse(url), headers: await _headers());
  }

  // ── Dashboard ─────────────────────────────────────────────
  static Future<Map<String, dynamic>> getDashboard() async {
    final res = await http.get(
      Uri.parse('${AppConstants.baseUrl}/dashboard/'),
      headers: await _headers(),
    );
    return jsonDecode(res.body);
  }

  // ── Recherche ─────────────────────────────────────────────
  static Future<Map<String, dynamic>> search(String query) async {
    final res = await http.get(
      Uri.parse('${AppConstants.baseUrl}/search/?q=${Uri.encodeComponent(query)}'),
      headers: await _headers(),
    );
    return jsonDecode(res.body);
  }

  // ── Freelances ─────────────────────────────────────────────
  static Future<List<dynamic>> getCategories() async {
    final res = await http.get(
      Uri.parse('${AppConstants.baseUrl}/categories/'),
      headers: await _headers(auth: false),
    );
    return jsonDecode(res.body);
  }
}
