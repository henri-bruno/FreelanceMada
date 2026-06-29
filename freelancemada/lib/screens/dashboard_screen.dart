import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../widgets/stat_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? _stats;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await ApiService.getDashboard();
      if (mounted) setState(() { _stats = data; _loading = false; });
    } catch (_) {
      if (mounted) setState(() { _loading = false; _error = 'Erreur de chargement.'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppConstants.goldColor))
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: AppConstants.errorColor)))
              : _stats == null
                  ? const Center(child: Text('Aucune donnée', style: TextStyle(color: AppConstants.textMuted)))
                  : RefreshIndicator(
                      color: AppConstants.goldColor,
                      onRefresh: _load,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header
                            Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Bonjour, ${user?.nom ?? ''}',
                                      style: const TextStyle(color: AppConstants.textPrimary, fontSize: 20, fontWeight: FontWeight.w700),
                                    ),
                                    Text(
                                      user?.role == 'freelance' ? 'Tableau de bord Freelance' : 'Tableau de bord Client',
                                      style: const TextStyle(color: AppConstants.textMuted, fontSize: 13),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            if (user?.isFreelance == true) ..._freelanceDashboard()
                            else if (user?.isClient == true) ..._clientDashboard()
                            else ..._adminDashboard(),

                            const SizedBox(height: 24),
                            // Navigation rapide
                            const Text('Actions rapides', style: TextStyle(color: AppConstants.textPrimary, fontWeight: FontWeight.w700, fontSize: 16)),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                _ActionChip('Missions', Icons.work_outline, () => context.push('/missions')),
                                _ActionChip('Services', Icons.star_outline, () => context.push('/services')),
                                _ActionChip('Contrats', Icons.description_outlined, () => context.push('/contrats')),
                                _ActionChip('Freelances', Icons.people_outline, () => context.push('/freelances')),
                                _ActionChip('Notifications', Icons.notifications_outlined, () => context.push('/notifications')),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
    );
  }

  List<Widget> _freelanceDashboard() {
    final s = _stats!;
    return [
      GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.6,
        children: [
          StatCard(
            label: 'Note moyenne',
            value: '${(s['note_moyenne'] ?? 0).toStringAsFixed(1)}/5',
            icon: Icons.star,
            color: AppConstants.goldColor,
          ),
          StatCard(
            label: 'Revenus totaux',
            value: '${(s['total_revenus'] ?? 0).toStringAsFixed(0)} Ar',
            icon: Icons.account_balance_wallet,
            color: AppConstants.successColor,
          ),
          StatCard(
            label: 'Missions terminées',
            value: '${s['missions_completees'] ?? 0}',
            icon: Icons.check_circle_outline,
            color: AppConstants.successColor,
          ),
          StatCard(
            label: 'En cours',
            value: '${s['missions_en_cours'] ?? 0}',
            icon: Icons.pending_outlined,
            color: AppConstants.infoColor,
          ),
          StatCard(
            label: 'Services actifs',
            value: '${s['nb_services'] ?? 0}',
            icon: Icons.storefront_outlined,
            color: AppConstants.warningColor,
          ),
          StatCard(
            label: 'Candidatures',
            value: '${s['candidatures_en_attente'] ?? 0}',
            icon: Icons.send_outlined,
            color: AppConstants.textMuted,
            subtitle: 'En attente',
          ),
        ],
      ),
    ];
  }

  List<Widget> _clientDashboard() {
    final s = _stats!;
    return [
      GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.6,
        children: [
          StatCard(
            label: 'Total missions',
            value: '${s['total_missions'] ?? 0}',
            icon: Icons.work_outline,
            color: AppConstants.goldColor,
          ),
          StatCard(
            label: 'En cours',
            value: '${s['missions_en_cours'] ?? 0}',
            icon: Icons.pending_outlined,
            color: AppConstants.infoColor,
          ),
          StatCard(
            label: 'Terminées',
            value: '${s['missions_terminees'] ?? 0}',
            icon: Icons.check_circle_outline,
            color: AppConstants.successColor,
          ),
          StatCard(
            label: 'Dépensé (total)',
            value: '${(s['total_depense'] ?? 0).toStringAsFixed(0)} Ar',
            icon: Icons.payments_outlined,
            color: AppConstants.errorColor,
          ),
          StatCard(
            label: 'Ce mois',
            value: '${(s['depense_mois'] ?? 0).toStringAsFixed(0)} Ar',
            icon: Icons.calendar_month,
            color: AppConstants.warningColor,
          ),
          StatCard(
            label: 'Candidatures reçues',
            value: '${s['nb_candidatures_recues'] ?? 0}',
            icon: Icons.people_outline,
            color: AppConstants.textMuted,
          ),
        ],
      ),
    ];
  }

  List<Widget> _adminDashboard() {
    final s = _stats!;
    return [
      GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.6,
        children: [
          StatCard(label: 'Utilisateurs', value: '${s['total_users'] ?? 0}', icon: Icons.people, color: AppConstants.goldColor),
          StatCard(label: 'Missions', value: '${s['total_missions'] ?? 0}', icon: Icons.work, color: AppConstants.infoColor),
          StatCard(label: 'Services', value: '${s['total_services'] ?? 0}', icon: Icons.storefront, color: AppConstants.warningColor),
          StatCard(label: 'Chiffre affaires', value: '${(s['total_paiements'] ?? 0).toStringAsFixed(0)} Ar', icon: Icons.payments, color: AppConstants.successColor),
        ],
      ),
    ];
  }
}

class _ActionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _ActionChip(this.label, this.icon, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppConstants.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppConstants.borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppConstants.goldColor),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(color: AppConstants.textSecondary, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
