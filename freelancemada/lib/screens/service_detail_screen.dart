import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../models/service.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../widgets/gold_badge.dart';
import '../widgets/user_avatar.dart';

class ServiceDetailScreen extends StatefulWidget {
  final int serviceId;
  const ServiceDetailScreen({super.key, required this.serviceId});

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  Service? _service;
  bool _loading = true;
  String _packageSelectionne = 'basic';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await ApiService.getService(widget.serviceId);
      if (mounted) setState(() { _service = Service.fromJson(data); _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  ServicePackage? get _selectedPackage {
    if (_service == null) return null;
    for (final p in _service!.packages) {
      if (p.niveau == _packageSelectionne) return p;
    }
    return _service!.packages.isNotEmpty ? _service!.packages.first : null;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppConstants.goldColor)));
    if (_service == null) return Scaffold(appBar: AppBar(), body: const Center(child: Text('Service introuvable')));

    final s = _service!;
    final user = context.read<AuthProvider>().user;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppConstants.primaryColor,
            flexibleSpace: FlexibleSpaceBar(
              background: s.imagePrincipale != null
                  ? Image.network(s.imagePrincipale!, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(color: AppConstants.card2Color))
                  : Container(
                      color: AppConstants.card2Color,
                      child: const Icon(Icons.work_outline, size: 60, color: AppConstants.textMuted),
                    ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titre & catégorie
                  GoldBadge(s.categorie),
                  const SizedBox(height: 10),
                  Text(s.titre, style: const TextStyle(color: AppConstants.textPrimary, fontSize: 20, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 14),
                  // Freelance
                  Row(
                    children: [
                      UserAvatar(nom: s.freelanceNom, radius: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(s.freelanceNom, style: const TextStyle(color: AppConstants.textPrimary, fontWeight: FontWeight.w600)),
                            Row(children: [
                              const Icon(Icons.star, size: 14, color: AppConstants.goldColor),
                              const SizedBox(width: 4),
                              Text('${s.freelanceNote.toStringAsFixed(1)} • ${s.nbVentes} ventes',
                                  style: const TextStyle(color: AppConstants.textMuted, fontSize: 12)),
                            ]),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.push('/chat/${s.freelanceId}?nom=${Uri.encodeComponent(s.freelanceNom)}'),
                        child: const Text('Contacter'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: AppConstants.borderColor),
                  const SizedBox(height: 16),
                  // Description
                  const Text('Description', style: TextStyle(color: AppConstants.textPrimary, fontWeight: FontWeight.w700, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(s.description, style: const TextStyle(color: AppConstants.textSecondary, height: 1.6)),
                  // Tags
                  if (s.tagsList.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: s.tagsList.map((t) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppConstants.card2Color,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppConstants.borderColor),
                        ),
                        child: Text(t, style: const TextStyle(color: AppConstants.textSecondary, fontSize: 12)),
                      )).toList(),
                    ),
                  ],
                  // Packages
                  if (s.packages.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Text('Formules', style: TextStyle(color: AppConstants.textPrimary, fontWeight: FontWeight.w700, fontSize: 16)),
                    const SizedBox(height: 12),
                    // Tabs
                    Row(
                      children: s.packages.map((p) => Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _packageSelectionne = p.niveau),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: _packageSelectionne == p.niveau ? AppConstants.goldColor : AppConstants.cardColor,
                              border: Border.all(color: AppConstants.borderColor),
                            ),
                            child: Text(
                              p.niveauLabel,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: _packageSelectionne == p.niveau ? Colors.black : AppConstants.textSecondary,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      )).toList(),
                    ),
                    if (_selectedPackage != null) _PackageDetail(pkg: _selectedPackage!),
                  ],
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _selectedPackage != null
          ? Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppConstants.surfaceColor,
                border: Border(top: BorderSide(color: AppConstants.borderColor)),
              ),
              child: Row(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Prix', style: TextStyle(color: AppConstants.textMuted, fontSize: 12)),
                      Text(
                        '${_selectedPackage!.prix.toStringAsFixed(0)} Ar',
                        style: const TextStyle(color: AppConstants.goldColor, fontSize: 20, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: user?.isClient == true ? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Commande envoyée ! Le freelance sera notifié.')),
                        );
                      } : null,
                      child: Text(user?.isClient == true ? 'Commander' : 'Connectez-vous en tant que client'),
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }
}

class _PackageDetail extends StatelessWidget {
  final ServicePackage pkg;
  const _PackageDetail({required this.pkg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        border: Border.all(color: AppConstants.borderColor),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(pkg.titre, style: const TextStyle(color: AppConstants.textPrimary, fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 8),
          Text(pkg.description, style: const TextStyle(color: AppConstants.textSecondary, height: 1.5)),
          const SizedBox(height: 12),
          Row(children: [
            _Detail(Icons.schedule, '${pkg.delaiJours} jours'),
            const SizedBox(width: 16),
            _Detail(Icons.refresh, '${pkg.nbRevisions} révision(s)'),
          ]),
          if (pkg.fonctionnalites.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...pkg.fonctionnalites.split('\n').where((l) => l.trim().isNotEmpty).map((line) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(children: [
                const Icon(Icons.check_circle, size: 16, color: AppConstants.successColor),
                const SizedBox(width: 8),
                Text(line.trim(), style: const TextStyle(color: AppConstants.textSecondary, fontSize: 13)),
              ]),
            )),
          ],
        ],
      ),
    );
  }
}

class _Detail extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Detail(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 16, color: AppConstants.textMuted),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(color: AppConstants.textSecondary, fontSize: 13)),
    ]);
  }
}
