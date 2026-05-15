import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../providers/mission_provider.dart';
import '../widgets/custom_button.dart';

class ApplyScreen extends StatefulWidget {
  final int missionId;
  const ApplyScreen({super.key, required this.missionId});

  @override
  State<ApplyScreen> createState() => _ApplyScreenState();
}

class _ApplyScreenState extends State<ApplyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _messageCtrl = TextEditingController();
  final _prixCtrl = TextEditingController();
  final _delaiCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _messageCtrl.dispose();
    _prixCtrl.dispose();
    _delaiCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final success = await context.read<MissionProvider>().applyToMission(
      widget.missionId,
      {
        'message': _messageCtrl.text.trim(),
        'prix_propose': double.parse(_prixCtrl.text),
        'delai': int.parse(_delaiCtrl.text),
      },
    );

    setState(() => _loading = false);
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Candidature envoyée avec succès !'),
          backgroundColor: AppConstants.successColor,
        ),
      );
      context.pop();
    } else {
      final error = context.read<MissionProvider>().error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Erreur lors de la candidature'),
          backgroundColor: AppConstants.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Postuler'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppConstants.goldColor),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppConstants.goldColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppConstants.goldColor.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: AppConstants.goldColor),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Présentez votre meilleure offre. Le client examinera votre candidature.',
                        style: TextStyle(color: AppConstants.textLight, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'Message de motivation',
                style: TextStyle(color: AppConstants.textLight, fontWeight: FontWeight.w600, fontSize: 15),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _messageCtrl,
                maxLines: 5,
                style: const TextStyle(color: AppConstants.textLight),
                decoration: const InputDecoration(
                  hintText: 'Décrivez votre expérience et pourquoi vous êtes le meilleur candidat...',
                  alignLabelWithHint: true,
                ),
                validator: (v) => v == null || v.trim().length < 20
                    ? 'Message trop court (min. 20 caractères)'
                    : null,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Prix proposé (Ar)',
                          style: TextStyle(color: AppConstants.textLight, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _prixCtrl,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: AppConstants.textLight),
                          decoration: const InputDecoration(
                            hintText: '50000',
                            prefixIcon: Icon(Icons.attach_money),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Obligatoire';
                            if (double.tryParse(v) == null) return 'Nombre invalide';
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Délai (jours)',
                          style: TextStyle(color: AppConstants.textLight, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _delaiCtrl,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: AppConstants.textLight),
                          decoration: const InputDecoration(
                            hintText: '7',
                            prefixIcon: Icon(Icons.schedule_outlined),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Obligatoire';
                            if (int.tryParse(v) == null) return 'Nombre entier';
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 36),
              GoldButton(
                label: 'Envoyer ma candidature',
                icon: Icons.send_rounded,
                loading: _loading,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
