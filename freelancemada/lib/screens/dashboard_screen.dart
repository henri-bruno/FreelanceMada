import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../providers/auth_provider.dart';
import '../providers/mission_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? _stats;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await context.read<MissionProvider>().fetchDashboard();
    setState(() {
      _stats = data;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().user;

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Tableau de bord'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppConstants.goldColor),
          onPressed: () => context.pop(),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppConstants.goldColor))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppConstants.goldColor.withValues(alpha: 0.2),
                          AppConstants.goldColor.withValues(alpha: 0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppConstants.goldColor.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.dashboard_rounded, color: AppConstants.goldColor, size: 32),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Vue d\'ensemble',
                                style: TextStyle(color: AppConstants.textLight,
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            Text(
                              user?.isClient == true ? 'Tableau client' : 'Tableau freelance',
                              style: const TextStyle(color: AppConstants.textMuted),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  if (_stats == null)
                    const Center(
                      child: Text('Impossible de charger les statistiques',
                          style: TextStyle(color: AppConstants.textMuted)),
                    )
                  else if (user?.isClient == true)
                    _ClientStats(stats: _stats!)
                  else if (user?.isFreelance == true)
                    _FreelanceStats(stats: _stats!)
                  else
                    _AdminStats(stats: _stats!),
                ],
              ),
            ),
    );
  }
}

class _ClientStats extends StatelessWidget {
  final Map<String, dynamic> stats;
  const _ClientStats({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Missions'),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.4,
          children: [
            _StatTile(
              label: 'Total missions',
              value: '${stats['total_missions'] ?? 0}',
              icon: Icons.work_outline,
              color: AppConstants.goldColor,
            ),
            _StatTile(
              label: 'En attente',
              value: '${stats['missions_en_attente'] ?? 0}',
              icon: Icons.pending_outlined,
              color: Colors.orange,
            ),
            _StatTile(
              label: 'En cours',
              value: '${stats['missions_en_cours'] ?? 0}',
              icon: Icons.play_circle_outline,
              color: Colors.blue,
            ),
            _StatTile(
              label: 'Terminées',
              value: '${stats['missions_terminees'] ?? 0}',
              icon: Icons.check_circle_outline,
              color: AppConstants.successColor,
            ),
          ],
        ),
        const SizedBox(height: 20),
        _StatTile(
          label: 'Candidatures reçues',
          value: '${stats['total_candidatures'] ?? 0}',
          icon: Icons.people_outline,
          color: AppConstants.goldColor,
          wide: true,
        ),
      ],
    );
  }
}

class _FreelanceStats extends StatelessWidget {
  final Map<String, dynamic> stats;
  const _FreelanceStats({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Activité'),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.4,
          children: [
            _StatTile(
              label: 'Candidatures',
              value: '${stats['total_candidatures'] ?? 0}',
              icon: Icons.send_outlined,
              color: AppConstants.goldColor,
            ),
            _StatTile(
              label: 'Acceptées',
              value: '${stats['candidatures_acceptees'] ?? 0}',
              icon: Icons.thumb_up_outlined,
              color: AppConstants.successColor,
            ),
            _StatTile(
              label: 'Missions actives',
              value: '${stats['missions_en_cours'] ?? 0}',
              icon: Icons.work_outline,
              color: Colors.blue,
            ),
            _StatTile(
              label: 'Terminées',
              value: '${stats['missions_terminees'] ?? 0}',
              icon: Icons.check_circle_outline,
              color: AppConstants.successColor,
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppConstants.cardColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppConstants.goldColor.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.star_rounded, color: AppConstants.goldColor, size: 32),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Note moyenne', style: TextStyle(color: AppConstants.textMuted)),
                  Text(
                    '${(stats['note_moyenne'] ?? 0.0).toStringAsFixed(1)} / 5',
                    style: const TextStyle(
                        color: AppConstants.goldColor, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AdminStats extends StatelessWidget {
  final Map<String, dynamic> stats;
  const _AdminStats({required this.stats});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        _StatTile(label: 'Utilisateurs', value: '${stats['total_users'] ?? 0}',
            icon: Icons.people_outline, color: AppConstants.goldColor),
        _StatTile(label: 'Missions', value: '${stats['total_missions'] ?? 0}',
            icon: Icons.work_outline, color: Colors.blue),
        _StatTile(label: 'Paiements', value: '${stats['total_paiements'] ?? 0}',
            icon: Icons.payment_outlined, color: AppConstants.successColor),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(title,
        style: const TextStyle(
            color: AppConstants.goldColor, fontSize: 16, fontWeight: FontWeight.bold));
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool wide;

  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.wide = false,
  });

  @override
  Widget build(BuildContext context) {
    final tile = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label, style: const TextStyle(color: AppConstants.textMuted, fontSize: 12)),
              Text(value,
                  style: TextStyle(
                      color: color, fontSize: 26, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
    return wide ? SizedBox(width: double.infinity, child: tile) : tile;
  }
}
