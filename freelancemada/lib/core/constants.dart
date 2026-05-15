import 'package:flutter/material.dart';

class AppConstants {
  // URL de l'API (10.0.2.2 = localhost depuis l'émulateur Android)
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  // Couleurs thème Noir + Or
  static const Color primaryColor = Color(0xFF1A1A2E);
  static const Color secondaryColor = Color(0xFF16213E);
  static const Color goldColor = Color(0xFFFFD700);
  static const Color goldDark = Color(0xFFC9A800);
  static const Color backgroundColor = Color(0xFF0F0F1A);
  static const Color cardColor = Color(0xFF1E1E35);
  static const Color textLight = Color(0xFFE0E0E0);
  static const Color textMuted = Color(0xFF888888);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color errorColor = Color(0xFFE53935);

  // Catégories de missions
  static const List<String> categories = [
    'Développement Web',
    'Développement Mobile',
    'Design Graphique',
    'Rédaction',
    'Marketing Digital',
    'Traduction',
    'Comptabilité',
    'Autre',
  ];
}
