import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../models/contrat.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../widgets/gold_badge.dart';

class ContratsScreen extends StatefulWidget {
  const ContratsScreen({super.key});

  @override
  State<ContratsScreen> createState() => _ContratsScreenState();
}

class _ContratsScreenState extends State<ContratsScreen> {
  List<Contrat> _contrats = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await ApiService.getContrats();
      if (mounted) {
        setState(() {
          _contrats = data.map((c) => Contrat.fromJson(c)).toList();
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _action(Contrat contrat, String action) async {
    try {
      await ApiService.updateContrat(contrat.id, {'action': action});
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Action effectuée avec succès.')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de l\'action.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().user;

    return Scaffold(
      appBar: AppBar(title: const Text('Mes Contrats')),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppConstants.goldColor))
          : _contrats.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.description_outlined, size: 64, color: AppConstants.textMuted),
                      SizedBox(height: 16),
                      Text('Aucun contrat', style: TextStyle(color: AppConstants.textMuted, fontSize: 16)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  color: AppConstants.goldColor,
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _contrats.length,
                    itemBuilder: (_, i) => _ContratCard(
                      contrat: _contrats[i],
                      userId: user?.id ?? 0,
                      onAction: _action,
                    ),
                  ),
                ),
    );
  }
}

class _ContratCard extends StatelessWidget {
  final Contrat contrat;
  final int userId;
  final void Function(Contrat, String) onAction;

  const _ContratCard({required this.contrat, required this.userId, required this.onAction});

  @override
  Widget build(BuildContext context) {
    final isClient = contrat.clientId == userId;
    final autreNom = isClient ? contrat.freelanceNom : contrat.clientNom;

    return Container(
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
              children: [
                Expanded(
                  child: Text(
                    contrat.titre,
                    style: const TextStyle(color: AppConstants.textPrimary, fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                ),
                StatusBadge(contrat.statut),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.person_outline, size: 14, color: AppConstants.textMuted),
                const SizedBox(width: 4),
                Text(
                  isClient ? 'Freelance: $autreNom' : 'Client: $autreNom',
                  style: const TextStyle(color: AppConstants.textSecondary, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _InfoItem(Icons.attach_money, '${contrat.montant.toStringAsFixed(0)} Ar'),
                const SizedBox(width: 16),
                _InfoItem(Icons.schedule, '${contrat.delaiJours} jours'),
                const Spacer(),
                if (contrat.dateFinPrevue != null)
                  Text(
                    'Fin: ${contrat.dateFinPrevue!.substring(0, 10)}',
                    style: const TextStyle(color: AppConstants.textMuted, fontSize: 11),
                  ),
              ],
            ),
            // Signature status
            if (contrat.statut == 'en_attente') ...[
              const SizedBox(height: 12),
              const Divider(color: AppConstants.borderColor),
              const SizedBox(height: 8),
              Row(
                children: [
                  _SignBadge('Client', contrat.signeClient),
                  const SizedBox(width: 8),
                  _SignBadge('Freelance', contrat.signeFreelance),
                ],
              ),
            ],
            // Actions
            _buildActions(context, isClient),
          ],
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context, bool isClient) {
    final actions = <Widget>[];

    if (contrat.statut == 'en_attente') {
      if (isClient && !contrat.signeClient) {
        actions.add(_ActionBtn('Signer', Icons.draw, () => onAction(contrat, 'signer_client')));
      }
      if (!isClient && !contrat.signeFreelance) {
        actions.add(_ActionBtn('Signer', Icons.draw, () => onAction(contrat, 'signer_freelance')));
      }
    }
    if (contrat.statut == 'en_cours' && !isClient) {
      actions.add(_ActionBtn('Livrer', Icons.send, () => onAction(contrat, 'livrer'), color: AppConstants.infoColor));
    }
    if (contrat.statut == 'livre' && isClient) {
      actions.add(_ActionBtn('Valider', Icons.check_circle, () => onAction(contrat, 'valider'), color: AppConstants.successColor));
    }

    if (actions.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(children: actions.map((a) => Padding(padding: const EdgeInsets.only(right: 8), child: a)).toList()),
    );
  }
}

class _SignBadge extends StatelessWidget {
  final String label;
  final bool signed;
  const _SignBadge(this.label, this.signed);

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(
        signed ? Icons.check_circle : Icons.radio_button_unchecked,
        size: 14,
        color: signed ? AppConstants.successColor : AppConstants.textMuted,
      ),
      const SizedBox(width: 4),
      Text(label, style: TextStyle(color: signed ? AppConstants.successColor : AppConstants.textMuted, fontSize: 12)),
    ]);
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoItem(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 14, color: AppConstants.textMuted),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(color: AppConstants.textSecondary, fontSize: 13)),
    ]);
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  const _ActionBtn(this.label, this.icon, this.onTap, {this.color = AppConstants.goldColor});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 14),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color),
        minimumSize: const Size(0, 36),
        padding: const EdgeInsets.symmetric(horizontal: 12),
      ),
    );
  }
}
