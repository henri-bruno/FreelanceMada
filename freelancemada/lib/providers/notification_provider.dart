import 'package:flutter/material.dart';
import '../models/notification.dart';
import '../services/api_service.dart';

class NotificationProvider extends ChangeNotifier {
  List<AppNotification> _notifications = [];
  bool _loading = false;
  int get unreadCount => _notifications.where((n) => !n.lu).length;
  List<AppNotification> get notifications => _notifications;
  bool get loading => _loading;

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    try {
      final data = await ApiService.getNotifications();
      final List<dynamic> results = data['results'] ?? data;
      _notifications = results.map((n) => AppNotification.fromJson(n)).toList();
    } catch (_) {}
    _loading = false;
    notifyListeners();
  }

  Future<void> markRead(int? id) async {
    await ApiService.markNotificationRead(id);
    if (id == null) {
      _notifications = _notifications.map((n) => AppNotification(
        id: n.id, userId: n.userId, type: n.type,
        titre: n.titre, message: n.message, lien: n.lien,
        lu: true, date: n.date,
      )).toList();
    } else {
      final idx = _notifications.indexWhere((n) => n.id == id);
      if (idx != -1) {
        final n = _notifications[idx];
        _notifications[idx] = AppNotification(
          id: n.id, userId: n.userId, type: n.type,
          titre: n.titre, message: n.message, lien: n.lien,
          lu: true, date: n.date,
        );
      }
    }
    notifyListeners();
  }
}
