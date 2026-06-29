import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/constants.dart';
import '../services/api_service.dart';

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
  String? _error;

  @override
  void dispose() {
    _messageCtrl.dispose();
    _prixCtrl.dispose();
    _delaiCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });

    try {
      final result = await ApiService.createCandidature({
        'mission': widget.missionId,
        'message': _messageCtrl.text.trim(),
        'prix_propose': double.parse(_prixCtrl.text),
        'delai': int.parse(_delaiCtrl.text),
      });

      setState(() => _loading = false);
      if (!mounted) return;

      if (result['id'] != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Candidature envoyée avec succès !'),
            backgroundColor: AppConstants.successColor,
          ),
        );
        context.pop();
      } else {
        final errMsg = result.values.first?.toString() ?? 'Erreur';
        setState(() => _error = errMsg);
      }
    } catch (_) {
      setState(() { _loading = false; _error = 'Erreur réseau.'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Postuler')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppConstants.goldColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppConstants.goldColor.withAlpha(80)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: AppConstants.goldColor),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Présentez votre meilleure offre. Le client examinera votre candidature.',
                        style: TextStyle(color: AppConstants.textSecondary, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Message
              const Text('Message de motivation',
                  style: TextStyle(color: AppConstants.textPrimary, fontWeight: FontWeight.w600, fontSize: 15)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _messageCtrl,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'Décrivez votre expérience et pourquoi vous êtes le meilleur candidat...',
                  alignLabelWithHint: true,
                ),
                validator: (v) => (v == null || v.trim().length < 20) ? 'Message trop court (min. 20 caractères)' : null,
              ),
              const SizedBox(height: 20),

              // Prix & délai
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Prix proposé (Ar)',
                            style: TextStyle(color: AppConstants.textPrimary, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _prixCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(hintText: '50000', prefixIcon: Icon(Icons.attach_money)),
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
                        const Text('Délai (jours)',
                            style: TextStyle(color: AppConstants.textPrimary, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _delaiCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(hintText: '7', prefixIcon: Icon(Icons.schedule_outlined)),
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

              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(_error!, style: const TextStyle(color: AppConstants.errorColor)),
              ],

              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _loading ? null : _submit,
                icon: _loading
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                    : const Icon(Icons.send_rounded),
                label: const Text('Envoyer ma candidature'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
