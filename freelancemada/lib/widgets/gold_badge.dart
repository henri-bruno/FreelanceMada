import 'package:flutter/material.dart';
import '../core/constants.dart';

class GoldBadge extends StatelessWidget {
  final String label;
  final Color? color;
  final Color? textColor;
  final double fontSize;

  const GoldBadge(this.label, {super.key, this.color, this.textColor, this.fontSize = 11});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color ?? AppConstants.goldMuted,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppConstants.goldColor.withAlpha(80)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor ?? AppConstants.goldColor,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class StatusBadge extends StatelessWidget {
  final String statut;
  const StatusBadge(this.statut, {super.key});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    switch (statut) {
      case 'en_attente':
        color = AppConstants.warningColor;
        label = 'En attente';
        break;
      case 'en_cours':
        color = AppConstants.infoColor;
        label = 'En cours';
        break;
      case 'termine':
      case 'valide':
        color = AppConstants.successColor;
        label = statut == 'valide' ? 'Validé' : 'Terminé';
        break;
      case 'annule':
        color = AppConstants.errorColor;
        label = 'Annulé';
        break;
      case 'livre':
        color = AppConstants.goldColor;
        label = 'Livré';
        break;
      default:
        color = AppConstants.textMuted;
        label = statut;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(100)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}
