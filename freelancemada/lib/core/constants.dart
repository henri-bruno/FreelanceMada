import 'package:flutter/material.dart';

class AppConstants {
  // Pour Chrome/Web et Windows desktop : localhost
  // Pour téléphone Android réel : adresse IP du PC sur le réseau WiFi
  static const String baseUrl = 'http://192.168.88.68:8000/api';

  // ── Palette Noir + Or ──────────────────────────────────────
  static const Color primaryColor   = Color(0xFF0A0A0F);
  static const Color surfaceColor   = Color(0xFF111118);
  static const Color cardColor      = Color(0xFF1A1A24);
  static const Color card2Color     = Color(0xFF222230);
  static const Color borderColor    = Color(0xFF2A2A3A);

  static const Color goldColor      = Color(0xFFFFD700);
  static const Color goldLight      = Color(0xFFFFE55C);
  static const Color goldDark       = Color(0xFFC9A800);
  static const Color goldMuted      = Color(0xFF7A6300);

  static const Color textPrimary    = Color(0xFFF0F0F0);
  static const Color textSecondary  = Color(0xFFAAAAAA);
  static const Color textMuted      = Color(0xFF666680);

  static const Color successColor   = Color(0xFF22C55E);
  static const Color errorColor     = Color(0xFFEF4444);
  static const Color warningColor   = Color(0xFFF59E0B);
  static const Color infoColor      = Color(0xFF3B82F6);

  // ── Gradients ─────────────────────────────────────────────
  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFFD700), Color(0xFFFFB300)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF0A0A0F), Color(0xFF111118)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1A1A24), Color(0xFF111118)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Catégories ────────────────────────────────────────────
  static const List<Map<String, String>> categories = [
    {'nom': 'Développement Web', 'icone': 'code', 'slug': 'dev-web'},
    {'nom': 'Mobile', 'icone': 'phone_android', 'slug': 'mobile'},
    {'nom': 'Design & Créatif', 'icone': 'palette', 'slug': 'design'},
    {'nom': 'Marketing Digital', 'icone': 'trending_up', 'slug': 'marketing'},
    {'nom': 'Rédaction & Traduction', 'icone': 'edit', 'slug': 'redaction'},
    {'nom': 'Data & IA', 'icone': 'analytics', 'slug': 'data-ia'},
    {'nom': 'SEO', 'icone': 'search', 'slug': 'seo'},
    {'nom': 'Vidéo & Audio', 'icone': 'videocam', 'slug': 'video-audio'},
    {'nom': 'Finance', 'icone': 'account_balance', 'slug': 'finance'},
    {'nom': 'Conseil', 'icone': 'lightbulb', 'slug': 'conseil'},
  ];

  static const List<String> niveaux = ['debutant', 'intermediaire', 'expert'];
  static const List<String> niveauxLabel = ['Débutant', 'Intermédiaire', 'Expert'];
  static const List<String> disponibilites = ['disponible', 'partiel', 'indisponible'];
  static const List<String> disponibilitesLabel = ['Disponible', 'Partiellement dispo.', 'Indisponible'];
}
