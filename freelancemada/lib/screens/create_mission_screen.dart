import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../providers/mission_provider.dart';
import '../widgets/custom_button.dart';

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
  String _categorie = AppConstants.categories.first;
  DateTime? _deadline;

  @override
  void dispose() {
    _titreCtrl.dispose();
    _descriptionCtrl.dispose();
    _budgetCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
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
        const SnackBar(content: Text('Veuillez choisir une deadline'),
            backgroundColor: AppConstants.errorColor),
      );
      return;
    }

    final success = await context.read<MissionProvider>().createMission({
      'titre': _titreCtrl.text.trim(),
      'description': _descriptionCtrl.text.trim(),
      'budget': double.parse(_budgetCtrl.text),
      'deadline': '${_deadline!.year}-${_deadline!.month.toString().padLeft(2, '0')}-${_deadline!.day.toString().padLeft(2, '0')}',
      'categorie': _categorie,
    });

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mission publiée !'), backgroundColor: AppConstants.successColor),
      );
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.read<MissionProvider>().error ?? 'Erreur'),
          backgroundColor: AppConstants.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MissionProvider>();
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Nouvelle mission'),
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
              TextFormField(
                controller: _titreCtrl,
                style: const TextStyle(color: AppConstants.textLight),
                decoration: const InputDecoration(
                  labelText: 'Titre de la mission',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Titre obligatoire' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionCtrl,
                maxLines: 4,
                style: const TextStyle(color: AppConstants.textLight),
                decoration: const InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(Icons.description_outlined),
                  alignLabelWithHint: true,
                ),
                validator: (v) => v == null || v.trim().length < 20
                    ? 'Description trop courte (min. 20 caractères)'
                    : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _budgetCtrl,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: AppConstants.textLight),
                      decoration: const InputDecoration(
                        labelText: 'Budget (Ar)',
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Obligatoire';
                        if (double.tryParse(v) == null) return 'Nombre invalide';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: _pickDeadline,
                      child: Container(
                        height: 56,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppConstants.secondaryColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF2A2A4A)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today_outlined,
                                color: AppConstants.goldColor, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              _deadline == null
                                  ? 'Deadline'
                                  : '${_deadline!.day}/${_deadline!.month}/${_deadline!.year}',
                              style: TextStyle(
                                color: _deadline == null
                                    ? AppConstants.textMuted
                                    : AppConstants.textLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _categorie,
                dropdownColor: AppConstants.cardColor,
                style: const TextStyle(color: AppConstants.textLight),
                decoration: const InputDecoration(
                  labelText: 'Catégorie',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: AppConstants.categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _categorie = v!),
              ),
              const SizedBox(height: 36),
              GoldButton(
                label: 'Publier la mission',
                icon: Icons.publish_rounded,
                loading: provider.loading,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
