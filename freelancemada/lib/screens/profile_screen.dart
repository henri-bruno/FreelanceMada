import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _editing = false;
  final _nomCtrl = TextEditingController();
  final _telCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _competencesCtrl = TextEditingController();
  final _experienceCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      _nomCtrl.text = user.nom;
      _telCtrl.text = user.telephone;
      _bioCtrl.text = user.freelanceProfile?.bio ?? '';
      _competencesCtrl.text = user.freelanceProfile?.competences ?? '';
      _experienceCtrl.text = '${user.freelanceProfile?.experience ?? 0}';
    }
  }

  @override
  void dispose() {
    _nomCtrl.dispose();
    _telCtrl.dispose();
    _bioCtrl.dispose();
    _competencesCtrl.dispose();
    _experienceCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final auth = context.read<AuthProvider>();
    final user = auth.user;
    if (user == null) return;

    final data = <String, dynamic>{
      'nom': _nomCtrl.text.trim(),
      'telephone': _telCtrl.text.trim(),
    };

    if (user.isFreelance) {
      data['freelance_profile'] = {
        'bio': _bioCtrl.text.trim(),
        'competences': _competencesCtrl.text.trim(),
        'experience': int.tryParse(_experienceCtrl.text) ?? 0,
      };
    }

    final success = await auth.updateProfile(data);
    if (!mounted) return;
    if (success) {
      setState(() => _editing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil mis à jour !'), backgroundColor: AppConstants.successColor),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    if (user == null) {
      return const Scaffold(
        backgroundColor: AppConstants.backgroundColor,
        body: Center(child: CircularProgressIndicator(color: AppConstants.goldColor)),
      );
    }

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Mon profil'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppConstants.goldColor),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(_editing ? Icons.close : Icons.edit_outlined, color: AppConstants.goldColor),
            onPressed: () => setState(() => _editing = !_editing),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 52,
                    backgroundColor: AppConstants.goldColor.withValues(alpha: 0.2),
                    child: Text(
                      user.nom.isNotEmpty ? user.nom[0].toUpperCase() : '?',
                      style: const TextStyle(
                          color: AppConstants.goldColor, fontSize: 36, fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (_editing)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AppConstants.goldColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt, size: 16, color: AppConstants.primaryColor),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (!_editing) ...[
              Text(user.nom,
                  style: const TextStyle(
                      color: AppConstants.textLight, fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(user.email, style: const TextStyle(color: AppConstants.textMuted)),
              const SizedBox(height: 8),
              _RoleBadge(role: user.role),
              if (user.isFreelance && user.freelanceProfile != null) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.star_rounded, color: AppConstants.goldColor, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      '${user.freelanceProfile!.noteMoyenne.toStringAsFixed(1)} / 5',
                      style: const TextStyle(color: AppConstants.goldColor, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ],
            const SizedBox(height: 24),
            if (_editing) ...[
              _buildEditForm(user.isFreelance),
              const SizedBox(height: 24),
              GoldButton(
                label: 'Enregistrer',
                loading: auth.loading,
                icon: Icons.save_outlined,
                onPressed: _save,
              ),
            ] else ...[
              _buildInfoSection(user),
            ],
            const SizedBox(height: 24),
            OutlineGoldButton(
              label: 'Se déconnecter',
              icon: Icons.logout_rounded,
              onPressed: () async {
                await context.read<AuthProvider>().logout();
                if (context.mounted) context.go('/login');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditForm(bool isFreelance) {
    return Column(
      children: [
        TextFormField(
          controller: _nomCtrl,
          style: const TextStyle(color: AppConstants.textLight),
          decoration: const InputDecoration(labelText: 'Nom', prefixIcon: Icon(Icons.person_outline)),
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _telCtrl,
          keyboardType: TextInputType.phone,
          style: const TextStyle(color: AppConstants.textLight),
          decoration: const InputDecoration(labelText: 'Téléphone', prefixIcon: Icon(Icons.phone_outlined)),
        ),
        if (isFreelance) ...[
          const SizedBox(height: 14),
          TextFormField(
            controller: _bioCtrl,
            maxLines: 3,
            style: const TextStyle(color: AppConstants.textLight),
            decoration: const InputDecoration(
                labelText: 'Bio', prefixIcon: Icon(Icons.info_outline), alignLabelWithHint: true),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _competencesCtrl,
            maxLines: 2,
            style: const TextStyle(color: AppConstants.textLight),
            decoration: const InputDecoration(
                labelText: 'Compétences (séparées par virgule)',
                prefixIcon: Icon(Icons.code_outlined), alignLabelWithHint: true),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _experienceCtrl,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: AppConstants.textLight),
            decoration: const InputDecoration(
                labelText: 'Années d\'expérience', prefixIcon: Icon(Icons.workspace_premium_outlined)),
          ),
        ],
      ],
    );
  }

  Widget _buildInfoSection(dynamic user) {
    return Column(
      children: [
        _InfoTile(icon: Icons.email_outlined, label: 'Email', value: user.email),
        if (user.telephone.isNotEmpty)
          _InfoTile(icon: Icons.phone_outlined, label: 'Téléphone', value: user.telephone),
        if (user.isFreelance && user.freelanceProfile != null) ...[
          if (user.freelanceProfile!.bio.isNotEmpty)
            _InfoTile(icon: Icons.info_outline, label: 'Bio', value: user.freelanceProfile!.bio),
          if (user.freelanceProfile!.competences.isNotEmpty)
            _InfoTile(
                icon: Icons.code_outlined,
                label: 'Compétences',
                value: user.freelanceProfile!.competences),
          _InfoTile(
              icon: Icons.workspace_premium_outlined,
              label: 'Expérience',
              value: '${user.freelanceProfile!.experience} ans'),
        ],
      ],
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final String role;
  const _RoleBadge({required this.role});

  @override
  Widget build(BuildContext context) {
    final label = role == 'client' ? 'Client' : role == 'freelance' ? 'Freelance' : 'Admin';
    final icon = role == 'client' ? Icons.business_center : Icons.code;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppConstants.goldColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppConstants.goldColor.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppConstants.goldColor),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: AppConstants.goldColor, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2A4A)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppConstants.goldColor, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: AppConstants.textMuted, fontSize: 11)),
              Text(value, style: const TextStyle(color: AppConstants.textLight, fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }
}
