import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../providers/service_provider.dart';

class CreateServiceScreen extends StatefulWidget {
  const CreateServiceScreen({super.key});

  @override
  State<CreateServiceScreen> createState() => _CreateServiceScreenState();
}

class _CreateServiceScreenState extends State<CreateServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titreCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _tagsCtrl = TextEditingController();
  final _prixCtrl = TextEditingController();
  final _delaiCtrl = TextEditingController();
  String _categorie = AppConstants.categories.first['nom']!;

  @override
  void dispose() {
    _titreCtrl.dispose();
    _descriptionCtrl.dispose();
    _tagsCtrl.dispose();
    _prixCtrl.dispose();
    _delaiCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<ServiceProvider>();
    final success = await provider.createService({
      'titre': _titreCtrl.text.trim(),
      'description': _descriptionCtrl.text.trim(),
      'categorie': _categorie,
      'tags': _tagsCtrl.text.trim(),
    }, {
      'niveau': 'basic',
      'titre': 'Offre Basic',
      'description': 'Prestation de base pour le service ${_titreCtrl.text.trim()}.',
      'prix': double.parse(_prixCtrl.text),
      'delai_jours': int.parse(_delaiCtrl.text),
      'nb_revisions': 1,
      'fonctionnalites': '',
    });

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Service créé avec succès !'), backgroundColor: AppConstants.successColor),
      );
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Erreur lors de la création du service.'),
          backgroundColor: AppConstants.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ServiceProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Nouveau Service')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
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
                        'Proposez vos compétences en créant un service clair et professionnel pour attirer des clients.',
                        style: TextStyle(color: AppConstants.textSecondary, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Titre
              TextFormField(
                controller: _titreCtrl,
                decoration: const InputDecoration(labelText: 'Titre du service', prefixIcon: Icon(Icons.title)),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Titre obligatoire' : null,
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionCtrl,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Description détaillée',
                  prefixIcon: Icon(Icons.description_outlined),
                  alignLabelWithHint: true,
                ),
                validator: (v) => (v == null || v.trim().length < 20) ? 'Min. 20 caractères' : null,
              ),
              const SizedBox(height: 16),

              // Catégorie
              DropdownButtonFormField<String>(
                initialValue: _categorie,
                dropdownColor: AppConstants.cardColor,
                decoration: const InputDecoration(labelText: 'Catégorie', prefixIcon: Icon(Icons.category_outlined)),
                items: AppConstants.categories
                    .map((c) => DropdownMenuItem(value: c['nom']!, child: Text(c['nom']!)))
                    .toList(),
                onChanged: (v) => setState(() => _categorie = v!),
              ),
              const SizedBox(height: 16),

              // Tags
              TextFormField(
                controller: _tagsCtrl,
                decoration: const InputDecoration(
                  labelText: 'Mots clés / Tags (séparés par virgule)',
                  prefixIcon: Icon(Icons.label_outline),
                  hintText: 'web, design, flutter...',
                ),
              ),
              const SizedBox(height: 24),

              const Divider(color: AppConstants.borderColor),
              const SizedBox(height: 16),

              // Tarification de base (Forfait)
              const Text(
                'Forfait Basic (Offre de base)',
                style: TextStyle(color: AppConstants.goldColor, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _prixCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Prix (Ar)', prefixIcon: Icon(Icons.attach_money)),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Obligatoire';
                        if (double.tryParse(v) == null) return 'Nombre invalide';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _delaiCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Délai (jours)', prefixIcon: Icon(Icons.schedule_outlined)),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Obligatoire';
                        if (int.tryParse(v) == null) return 'Nombre entier';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Bouton de soumission
              ElevatedButton.icon(
                onPressed: provider.loading ? null : _submit,
                icon: provider.loading
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                    : const Icon(Icons.publish_rounded),
                label: const Text('Créer le service'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
