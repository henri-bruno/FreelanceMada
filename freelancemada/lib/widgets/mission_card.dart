import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../models/mission.dart';

class MissionCard extends StatelessWidget {
  final Mission mission;
  final VoidCallback? onTap;

  const MissionCard({super.key, required this.mission, this.onTap});

  Color _statutColor() {
    switch (mission.statut) {
      case 'en_attente': return Colors.orange;
      case 'en_cours': return AppConstants.goldColor;
      case 'termine': return AppConstants.successColor;
      case 'annule': return AppConstants.errorColor;
      default: return AppConstants.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppConstants.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppConstants.goldColor.withValues(alpha: 0.25),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      mission.titre,
                      style: const TextStyle(
                        color: AppConstants.textLight,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _StatutBadge(label: mission.statutLabel, color: _statutColor()),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                mission.description,
                style: const TextStyle(color: AppConstants.textMuted, fontSize: 13),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _InfoChip(icon: Icons.attach_money, label: '${mission.budget.toStringAsFixed(0)} Ar'),
                  const SizedBox(width: 8),
                  _InfoChip(icon: Icons.category_outlined, label: mission.categorie),
                  const Spacer(),
                  _InfoChip(
                    icon: Icons.people_outline,
                    label: '${mission.nbCandidatures}',
                    color: AppConstants.goldColor,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.person_outline, size: 14, color: AppConstants.textMuted),
                  const SizedBox(width: 4),
                  Text(
                    mission.clientNom,
                    style: const TextStyle(color: AppConstants.textMuted, fontSize: 12),
                  ),
                  const Spacer(),
                  const Icon(Icons.calendar_today_outlined, size: 12, color: AppConstants.textMuted),
                  const SizedBox(width: 4),
                  Text(
                    mission.deadline,
                    style: const TextStyle(color: AppConstants.textMuted, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatutBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatutBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    this.color = AppConstants.textMuted,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(color: color, fontSize: 12)),
      ],
    );
  }
}
