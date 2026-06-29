class AppNotification {
  final int id;
  final int userId;
  final String type;
  final String titre;
  final String message;
  final String lien;
  final bool lu;
  final String date;

  AppNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.titre,
    required this.message,
    this.lien = '',
    required this.lu,
    required this.date,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) => AppNotification(
    id: json['id'],
    userId: json['user'] ?? 0,
    type: json['type'] ?? 'systeme',
    titre: json['titre'] ?? '',
    message: json['message'] ?? '',
    lien: json['lien'] ?? '',
    lu: json['lu'] ?? false,
    date: json['date'] ?? '',
  );
}
