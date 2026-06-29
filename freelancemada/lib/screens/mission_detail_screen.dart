import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../models/mission.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../widgets/gold_badge.dart';

class MissionDetailScreen extends StatefulWidget {
  final int missionId;
  const MissionDetailScreen({super.key, required this.missionId});

  @override
  State<MissionDetailScreen> createState() => _MissionDetailScreenState();
}

class _MissionDetailScreenState extends State<MissionDetailScreen> {
  Mission? _mission;
  List<dynamic> _candidatures = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final mData = await ApiService.getMission(widget.missionId);
      final cData = await ApiService.getCandidatures(missionId: widget.missionId);
      if (mounted) setState(() {
        _mission = Mission.fromJson(mData);
        _candidatures = cData['results'] ?? cData;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _accepterCandidature(int candidatureId) async {
    try {
      await ApiService.updateCandidature(candidatureId, {'statut': 'accepte'});
      await _load();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Candidature acceptée !')),
      );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().user;

    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppConstants.goldColor)));
    if (_mission == null) return Scaffold(appBar: AppBar(), body: const Center(child: Text('Mission introuvable')));

    final m = _mission!;
    final isOwner = user?.id == m.clientId;
    final isFreelance = user?.isFreelance == true;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppConstants.primaryColor,
            title: Text(m.titre, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titre + statut
                  Row(
                    children: [
                      Expanded(child: Text(m.titre, style: const TextStyle(color: AppConstants.textPrimary, fontSize: 20, fontWeight: FontWeight.w800))),
                      StatusBadge(m.statut),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(children: [
                    const Icon(Icons.person_outline, size: 14, color: AppConstants.textMuted),
                    const SizedBox(width: 4),
                    Text(m.clientNom, style: const TextStyle(color: AppConstants.textMuted, fontSize: 13)),
                    const SizedBox(width: 12),
                    const Icon(Icons.visibility_outlined, size: 14, color: AppConstants.textMuted),
                    const SizedBox(width: 4),
                    Text('${m.nbVues} vues', style: const TextStyle(color: AppConstants.textMuted, fontSize: 13)),
                  ]),
                  const SizedBox(height: 16),

                  // Infos clés
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppConstants.cardColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppConstants.borderColor),
                    ),
                    child: Row(
                      children: [
                        Expanded(child: _InfoCol('Budget', '${m.budget.toStringAsFixed(0)} Ar', AppConstants.goldColor)),
                        Container(width: 1, height: 40, color: AppConstants.borderColor),
                        Expanded(child: _InfoCol('Deadline', m.deadline, AppConstants.textSecondary)),
                        Container(width: 1, height: 40, color: AppConstants.borderColor),
                        Expanded(child: _InfoCol('Niveau', m.niveauLabel, AppConstants.textSecondary)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Catégorie & compétences
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    GoldBadge(m.categorie),
                    ...m.competencesRequises.split(',')
                        .map((c) => c.trim())
                        .where((c) => c.isNotEmpty)
                        .map((c) => GoldBadge(c, color: AppConstants.card2Color, textColor: AppConstants.textSecondary)),
                  ]),
                  const SizedBox(height: 20),

                  // Description
                  const Text('Description', style: TextStyle(color: AppConstants.textPrimary, fontWeight: FontWeight.w700, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(m.description, style: const TextStyle(color: AppConstants.textSecondary, height: 1.6)),
                  const SizedBox(height: 24),

                  // Candidatures (si owner)
                  if (isOwner && _candidatures.isNotEmpty) ...[
                    Text('Candidatures (${_candidatures.length})',
                        style: const TextStyle(color: AppConstants.textPrimary, fontWeight: FontWeight.w700, fontSize: 16)),
                    const SizedBox(height: 12),
                    ..._candidatures.map((c) => _CandidatureCard(
                      candidature: c,
                      onAccept: () => _accepterCandidature(c['id']),
                      onChat: () => context.push('/chat/${c['freelance']}?nom=${Uri.encodeComponent(c['freelance_nom'] ?? 'Freelance')}'),
                    )),
                    const SizedBox(height: 80),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: isFreelance && m.statut == 'en_attente'
          ? Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppConstants.surfaceColor,
                border: Border(top: BorderSide(color: AppConstants.borderColor)),
              ),
              child: ElevatedButton.icon(
                onPressed: () => context.push('/missions/${m.id}/apply'),
                icon: const Icon(Icons.send),
                label: const Text('Postuler à cette mission'),
              ),
            )
          : null,
    );
  }
}

class _InfoCol extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  const _InfoCol(this.label, this.value, this.valueColor);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: AppConstants.textMuted, fontSize: 11)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: valueColor, fontWeight: FontWeight.w700, fontSize: 14), textAlign: TextAlign.center),
      ],
    );
  }
}

class _CandidatureCard extends StatelessWidget {
  final dynamic candidature;
  final VoidCallback onAccept;
  final VoidCallback onChat;
  const _CandidatureCard({required this.candidature, required this.onAccept, required this.onChat});

  @override
  Widget build(BuildContext context) {
    final c = candidature;
    final statut = c['statut'] ?? 'en_attente';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppConstants.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppConstants.card2Color,
                child: Text((c['freelance_nom'] ?? '?')[0], style: const TextStyle(color: AppConstants.goldColor)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c['freelance_nom'] ?? '', style: const TextStyle(color: AppConstants.textPrimary, fontWeight: FontWeight.w600)),
                    Row(children: [
                      const Icon(Icons.star, size: 12, color: AppConstants.goldColor),
                      const SizedBox(width: 2),
                      Text('${(c['freelance_note'] ?? 0).toStringAsFixed(1)}', style: const TextStyle(color: AppConstants.textMuted, fontSize: 12)),
                    ]),
                  ],
                ),
              ),
              StatusBadge(statut),
            ],
          ),
          const SizedBox(height: 10),
          Text(c['message'] ?? '', style: const TextStyle(color: AppConstants.textSecondary, fontSize: 13, height: 1.4), maxLines: 3, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 10),
          Row(
            children: [
              _Pill(Icons.attach_money, '${(c['prix_propose'] ?? 0).toStringAsFixed(0)} Ar'),
              const SizedBox(width: 8),
              _Pill(Icons.schedule, '${c['delai'] ?? 0} jours'),
              const Spacer(),
              if (statut == 'en_attente') ...[
                IconButton(
                  icon: const Icon(Icons.chat_bubble_outline, color: AppConstants.infoColor, size: 20),
                  onPressed: onChat,
                  tooltip: 'Contacter',
                ),
                ElevatedButton(
                  onPressed: onAccept,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0, 32),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  child: const Text('Accepter', style: TextStyle(fontSize: 12)),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Pill(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 13, color: AppConstants.textMuted),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(color: AppConstants.textSecondary, fontSize: 12)),
    ]);
  }
}
