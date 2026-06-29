import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../models/mission.dart';
import 'gold_badge.dart';

class MissionCard extends StatelessWidget {
  final Mission mission;
  final VoidCallback? onTap;

  const MissionCard({super.key, required this.mission, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppConstants.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppConstants.borderColor),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mission.titre,
                          style: const TextStyle(
                            color: AppConstants.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          mission.clientNom,
                          style: const TextStyle(color: AppConstants.textMuted, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  StatusBadge(mission.statut),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                mission.description,
                style: const TextStyle(color: AppConstants.textSecondary, fontSize: 13, height: 1.5),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              // Catégorie & niveau
              Wrap(
                spacing: 6,
                children: [
                  _Chip(Icons.category_outlined, mission.categorie),
                  _Chip(Icons.bar_chart, mission.niveauLabel),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                children: [
                  // Budget
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Budget', style: TextStyle(color: AppConstants.textMuted, fontSize: 11)),
                      Text(
                        '${mission.budget.toStringAsFixed(0)} Ar',
                        style: const TextStyle(
                          color: AppConstants.goldColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  // Deadline
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Deadline', style: TextStyle(color: AppConstants.textMuted, fontSize: 11)),
                      Text(
                        mission.deadline,
                        style: const TextStyle(color: AppConstants.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Candidatures
                  Row(
                    children: [
                      const Icon(Icons.people_outline, size: 14, color: AppConstants.textMuted),
                      const SizedBox(width: 4),
                      Text(
                        '${mission.nbCandidatures}',
                        style: const TextStyle(color: AppConstants.textSecondary, fontSize: 13),
                      ),
                    ],
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

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Chip(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppConstants.card2Color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppConstants.borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppConstants.textMuted),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(color: AppConstants.textSecondary, fontSize: 11)),
        ],
      ),
    );
  }
}
