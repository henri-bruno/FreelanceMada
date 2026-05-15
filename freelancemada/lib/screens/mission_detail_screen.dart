import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../models/mission.dart';
import '../models/candidature.dart';
import '../providers/auth_provider.dart';
import '../providers/mission_provider.dart';
import '../widgets/custom_button.dart';

class MissionDetailScreen extends StatefulWidget {
  final int missionId;
  const MissionDetailScreen({super.key, required this.missionId});

  @override
  State<MissionDetailScreen> createState() => _MissionDetailScreenState();
}

class _MissionDetailScreenState extends State<MissionDetailScreen> {
  Mission? _mission;
  List<Candidature> _candidatures = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final provider = context.read<MissionProvider>();
    final mission = await provider.fetchMissionDetail(widget.missionId);
    await provider.fetchCandidatures(widget.missionId);
    setState(() {
      _mission = mission;
      _candidatures = provider.candidatures;
      _loading = false;
    });
  }

  Color _statutColor(String statut) {
    switch (statut) {
      case 'en_attente': return Colors.orange;
      case 'en_cours': return AppConstants.goldColor;
      case 'termine': return AppConstants.successColor;
      default: return AppConstants.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().user;

    if (_loading) {
      return const Scaffold(
        backgroundColor: AppConstants.backgroundColor,
        body: Center(child: CircularProgressIndicator(color: AppConstants.goldColor)),
      );
    }

    if (_mission == null) {
      return Scaffold(
        backgroundColor: AppConstants.backgroundColor,
        appBar: AppBar(title: const Text('Mission introuvable')),
        body: const Center(
          child: Text('Mission introuvable', style: TextStyle(color: AppConstants.textMuted)),
        ),
      );
    }

    final m = _mission!;
    final isClient = user?.isClient == true && user?.id == m.clientId;
    final isFreelance = user?.isFreelance == true;
    final alreadyApplied = _candidatures.any((c) => c.freelanceId == user?.id);

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Détail mission'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppConstants.goldColor),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête
            Row(
              children: [
                Expanded(
                  child: Text(
                    m.titre,
                    style: const TextStyle(
                      color: AppConstants.textLight,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _StatutBadge(statut: m.statutLabel, color: _statutColor(m.statut)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.person_outline, size: 16, color: AppConstants.textMuted),
                const SizedBox(width: 4),
                Text('Par ${m.clientNom}',
                    style: const TextStyle(color: AppConstants.textMuted, fontSize: 13)),
                const Spacer(),
                const Icon(Icons.calendar_today_outlined, size: 14, color: AppConstants.textMuted),
                const SizedBox(width: 4),
                Text(m.dateCreation.split('T').first,
                    style: const TextStyle(color: AppConstants.textMuted, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 20),
            // Infos clés
            Row(
              children: [
                _InfoBox(icon: Icons.attach_money, label: 'Budget',
                    value: '${m.budget.toStringAsFixed(0)} Ar'),
                const SizedBox(width: 12),
                _InfoBox(icon: Icons.flag_outlined, label: 'Deadline', value: m.deadline),
                const SizedBox(width: 12),
                _InfoBox(icon: Icons.category_outlined, label: 'Catégorie', value: m.categorie),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Description',
                style: TextStyle(color: AppConstants.goldColor, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppConstants.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF2A2A4A)),
              ),
              child: Text(m.description,
                  style: const TextStyle(color: AppConstants.textLight, height: 1.6)),
            ),
            const SizedBox(height: 24),
            // Candidatures (visible pour le client propriétaire)
            if (isClient && _candidatures.isNotEmpty) ...[
              Text(
                'Candidatures (${_candidatures.length})',
                style: const TextStyle(
                    color: AppConstants.goldColor, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ..._candidatures.map((c) => _CandidatureCard(
                candidature: c,
                onAccept: () => _updateCandidature(c.id, 'accepte'),
                onRefuse: () => _updateCandidature(c.id, 'refuse'),
              )),
              const SizedBox(height: 16),
            ],
            const SizedBox(height: 8),
            // Bouton postuler
            if (isFreelance && m.statut == 'en_attente') ...[
              if (alreadyApplied)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppConstants.successColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppConstants.successColor.withValues(alpha: 0.5)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline, color: AppConstants.successColor),
                      SizedBox(width: 8),
                      Text('Candidature envoyée',
                          style: TextStyle(color: AppConstants.successColor, fontWeight: FontWeight.bold)),
                    ],
                  ),
                )
              else
                GoldButton(
                  label: 'Postuler à cette mission',
                  icon: Icons.send_outlined,
                  onPressed: () => context.push('/apply/${m.id}'),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _updateCandidature(int candidatureId, String statut) async {
    final provider = context.read<MissionProvider>();
    try {
      await provider.fetchCandidatures(widget.missionId);
      setState(() => _candidatures = provider.candidatures);
    } catch (_) {}
  }
}

class _StatutBadge extends StatelessWidget {
  final String statut;
  final Color color;
  const _StatutBadge({required this.statut, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(statut, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoBox({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppConstants.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF2A2A4A)),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppConstants.goldColor, size: 20),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(color: AppConstants.textMuted, fontSize: 11)),
            const SizedBox(height: 2),
            Text(value,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppConstants.textLight, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _CandidatureCard extends StatelessWidget {
  final Candidature candidature;
  final VoidCallback onAccept;
  final VoidCallback onRefuse;
  const _CandidatureCard({required this.candidature, required this.onAccept, required this.onRefuse});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2A4A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person_outline, color: AppConstants.goldColor, size: 16),
              const SizedBox(width: 6),
              Text(candidature.freelanceNom,
                  style: const TextStyle(color: AppConstants.textLight, fontWeight: FontWeight.bold)),
              const Spacer(),
              Text('${candidature.prixPropose.toStringAsFixed(0)} Ar',
                  style: const TextStyle(color: AppConstants.goldColor, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 6),
          Text(candidature.message,
              style: const TextStyle(color: AppConstants.textMuted, fontSize: 13),
              maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 6),
          Text('Délai : ${candidature.delai} jours',
              style: const TextStyle(color: AppConstants.textMuted, fontSize: 12)),
          if (candidature.statut == 'en_attente') ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onRefuse,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppConstants.errorColor,
                      side: const BorderSide(color: AppConstants.errorColor),
                    ),
                    child: const Text('Refuser'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onAccept,
                    child: const Text('Accepter'),
                  ),
                ),
              ],
            ),
          ] else
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: candidature.statut == 'accepte'
                    ? AppConstants.successColor.withValues(alpha: 0.15)
                    : AppConstants.errorColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                candidature.statutLabel,
                style: TextStyle(
                  color: candidature.statut == 'accepte'
                      ? AppConstants.successColor
                      : AppConstants.errorColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
