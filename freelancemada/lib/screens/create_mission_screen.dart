import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../providers/mission_provider.dart';

class CreateMissionScreen extends StatefulWidget {
  const CreateMissionScreen({super.key});

  @override
  State<CreateMissionScreen> createState() => _CreateMissionScreenState();
}

class _CreateMissionScreenState extends State<CreateMissionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titreCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _budgetCtrl = TextEditingController();
  final _budgetMinCtrl = TextEditingController();
  final _competencesCtrl = TextEditingController();
  String _categorie = AppConstants.categories.first['nom']!;
  String _niveau = 'intermediaire';
  DateTime? _deadline;

  @override
  void dispose() {
    _titreCtrl.dispose();
    _descriptionCtrl.dispose();
    _budgetCtrl.dispose();
    _budgetMinCtrl.dispose();
    _competencesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(primary: AppConstants.goldColor),
        ),
        child: child!,
      ),
    );
    if (date != null) setState(() => _deadline = date);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_deadline == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez choisir une deadline'), backgroundColor: AppConstants.errorColor),
      );
      return;
    }

    final deadlineStr = '${_deadline!.year}-${_deadline!.month.toString().padLeft(2, '0')}-${_deadline!.day.toString().padLeft(2, '0')}';
    final success = await context.read<MissionProvider>().createMission({
      'titre': _titreCtrl.text.trim(),
      'description': _descriptionCtrl.text.trim(),
      'budget_min': double.tryParse(_budgetMinCtrl.text) ?? 0,
      'budget': double.parse(_budgetCtrl.text),
      'deadline': deadlineStr,
      'categorie': _categorie,
      'competences_requises': _competencesCtrl.text.trim(),
      'niveau_experience': _niveau,
    });

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mission publiée avec succès !'), backgroundColor: AppConstants.successColor),
      );
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.read<MissionProvider>().error ?? 'Erreur lors de la publication.'),
          backgroundColor: AppConstants.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MissionProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Nouvelle mission')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titre
              TextFormField(
                controller: _titreCtrl,
                decoration: const InputDecoration(labelText: 'Titre de la mission', prefixIcon: Icon(Icons.title)),
                validator: (v) => (v == null || v.isEmpty) ? 'Titre obligatoire' : null,
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

              // Budget min & max
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _budgetMinCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Budget min (Ar)', prefixIcon: Icon(Icons.attach_money)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _budgetCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Budget max (Ar)', prefixIcon: Icon(Icons.attach_money)),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Obligatoire';
                        if (double.tryParse(v) == null) return 'Nombre invalide';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Deadline
              GestureDetector(
                onTap: _pickDeadline,
                child: Container(
                  height: 54,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppConstants.cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppConstants.borderColor),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, color: AppConstants.goldColor, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        _deadline == null
                            ? 'Choisir une deadline'
                            : 'Deadline : ${_deadline!.day}/${_deadline!.month}/${_deadline!.year}',
                        style: TextStyle(
                          color: _deadline == null ? AppConstants.textMuted : AppConstants.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
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

              // Niveau
              DropdownButtonFormField<String>(
                initialValue: _niveau,
                dropdownColor: AppConstants.cardColor,
                decoration: const InputDecoration(labelText: 'Niveau requis', prefixIcon: Icon(Icons.bar_chart)),
                items: const [
                  DropdownMenuItem(value: 'debutant', child: Text('Débutant')),
                  DropdownMenuItem(value: 'intermediaire', child: Text('Intermédiaire')),
                  DropdownMenuItem(value: 'expert', child: Text('Expert')),
                ],
                onChanged: (v) => setState(() => _niveau = v!),
              ),
              const SizedBox(height: 16),

              // Compétences
              TextFormField(
                controller: _competencesCtrl,
                decoration: const InputDecoration(
                  labelText: 'Compétences requises (séparées par virgule)',
                  prefixIcon: Icon(Icons.psychology_outlined),
                  hintText: 'Flutter, Django, UI/UX...',
                ),
              ),
              const SizedBox(height: 32),

              // Bouton
              ElevatedButton.icon(
                onPressed: provider.loading ? null : _submit,
                icon: provider.loading
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                    : const Icon(Icons.publish_rounded),
                label: const Text('Publier la mission'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
