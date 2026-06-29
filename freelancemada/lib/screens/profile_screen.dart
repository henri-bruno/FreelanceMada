import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../providers/auth_provider.dart';
import '../widgets/user_avatar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _editing = false;
  final _nomCtrl = TextEditingController();
  final _prenomCtrl = TextEditingController();
  final _telCtrl = TextEditingController();
  final _villeCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _titreCtrl = TextEditingController();
  final _competencesCtrl = TextEditingController();
  final _experienceCtrl = TextEditingController();
  final _tarifCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initFields();
  }

  void _initFields() {
    final user = context.read<AuthProvider>().user;
    if (user == null) return;
    _nomCtrl.text = user.nom;
    _prenomCtrl.text = user.prenom;
    _telCtrl.text = user.telephone;
    _villeCtrl.text = user.ville;
    _bioCtrl.text = user.freelanceProfile?.bio ?? '';
    _titreCtrl.text = user.freelanceProfile?.titreProfessionnel ?? '';
    _competencesCtrl.text = user.freelanceProfile?.competences ?? '';
    _experienceCtrl.text = '${user.freelanceProfile?.experience ?? 0}';
    _tarifCtrl.text = '${user.freelanceProfile?.tarifHoraire ?? ''}';
  }

  @override
  void dispose() {
    for (final c in [_nomCtrl, _prenomCtrl, _telCtrl, _villeCtrl, _bioCtrl, _titreCtrl, _competencesCtrl, _experienceCtrl, _tarifCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final auth = context.read<AuthProvider>();
    final user = auth.user;
    if (user == null) return;

    final data = <String, dynamic>{
      'nom': _nomCtrl.text.trim(),
      'prenom': _prenomCtrl.text.trim(),
      'telephone': _telCtrl.text.trim(),
      'ville': _villeCtrl.text.trim(),
    };

    if (user.isFreelance) {
      data['freelance_profile'] = {
        'bio': _bioCtrl.text.trim(),
        'titre_professionnel': _titreCtrl.text.trim(),
        'competences': _competencesCtrl.text.trim(),
        'experience': int.tryParse(_experienceCtrl.text) ?? 0,
        'tarif_horaire': double.tryParse(_tarifCtrl.text),
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
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppConstants.goldColor)));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Profil'),
        actions: [
          IconButton(
            icon: Icon(_editing ? Icons.close : Icons.edit_outlined),
            onPressed: () {
              if (_editing) _initFields();
              setState(() => _editing = !_editing);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Header profil
            _ProfileHeader(user: user, editing: _editing),
            const SizedBox(height: 24),

            // Formulaire ou infos
            if (_editing)
              _EditForm(
                nomCtrl: _nomCtrl,
                prenomCtrl: _prenomCtrl,
                telCtrl: _telCtrl,
                villeCtrl: _villeCtrl,
                bioCtrl: _bioCtrl,
                titreCtrl: _titreCtrl,
                competencesCtrl: _competencesCtrl,
                experienceCtrl: _experienceCtrl,
                tarifCtrl: _tarifCtrl,
                isFreelance: user.isFreelance,
              )
            else
              _InfoSection(user: user),

            const SizedBox(height: 20),

            if (_editing)
              ElevatedButton.icon(
                onPressed: auth.loading ? null : _save,
                icon: auth.loading
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                    : const Icon(Icons.save_outlined),
                label: const Text('Enregistrer'),
              )
            else
              OutlinedButton.icon(
                onPressed: () async {
                  await context.read<AuthProvider>().logout();
                  if (context.mounted) context.go('/login');
                },
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Se déconnecter'),
                style: OutlinedButton.styleFrom(foregroundColor: AppConstants.errorColor, side: const BorderSide(color: AppConstants.errorColor)),
              ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final dynamic user;
  final bool editing;
  const _ProfileHeader({required this.user, required this.editing});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        UserAvatar(photoUrl: user.photo, nom: user.nomComplet, radius: 48, isOnline: user.isOnline),
        const SizedBox(height: 12),
        Text(user.nomComplet, style: const TextStyle(color: AppConstants.textPrimary, fontSize: 22, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text(user.email, style: const TextStyle(color: AppConstants.textMuted, fontSize: 13)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            color: AppConstants.goldColor.withAlpha(30),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppConstants.goldColor.withAlpha(80)),
          ),
          child: Text(
            user.role == 'client' ? 'Client' : user.role == 'freelance' ? 'Freelance' : 'Admin',
            style: const TextStyle(color: AppConstants.goldColor, fontWeight: FontWeight.w700),
          ),
        ),
        if (user.isFreelance && user.freelanceProfile != null) ...[
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.star, color: AppConstants.goldColor, size: 16),
            const SizedBox(width: 4),
            Text(
              '${user.freelanceProfile!.noteMoyenne.toStringAsFixed(1)} (${user.freelanceProfile!.nbAvis} avis)',
              style: const TextStyle(color: AppConstants.goldColor, fontWeight: FontWeight.w600),
            ),
          ]),
        ],
      ],
    );
  }
}

class _InfoSection extends StatelessWidget {
  final dynamic user;
  const _InfoSection({required this.user});

  @override
  Widget build(BuildContext context) {
    final profile = user.freelanceProfile;
    return Column(
      children: [
        if (user.telephone.isNotEmpty) _Tile(Icons.phone_outlined, 'Téléphone', user.telephone),
        if (user.ville.isNotEmpty) _Tile(Icons.location_on_outlined, 'Ville', '${user.ville}, ${user.pays}'),
        if (profile != null) ...[
          if (profile.titreProfessionnel.isNotEmpty) _Tile(Icons.work_outline, 'Titre', profile.titreProfessionnel),
          if (profile.bio.isNotEmpty) _Tile(Icons.info_outline, 'Bio', profile.bio),
          if (profile.competences.isNotEmpty) _Tile(Icons.psychology_outlined, 'Compétences', profile.competences),
          _Tile(Icons.workspace_premium_outlined, 'Expérience', '${profile.experience} ans'),
          if (profile.tarifHoraire != null) _Tile(Icons.attach_money, 'Tarif horaire', '${profile.tarifHoraire!.toStringAsFixed(0)} Ar/h'),
        ],
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _Tile(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppConstants.borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppConstants.goldColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: AppConstants.textMuted, fontSize: 11)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(color: AppConstants.textPrimary, fontSize: 14, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EditForm extends StatelessWidget {
  final TextEditingController nomCtrl, prenomCtrl, telCtrl, villeCtrl;
  final TextEditingController bioCtrl, titreCtrl, competencesCtrl, experienceCtrl, tarifCtrl;
  final bool isFreelance;

  const _EditForm({
    required this.nomCtrl, required this.prenomCtrl,
    required this.telCtrl, required this.villeCtrl,
    required this.bioCtrl, required this.titreCtrl,
    required this.competencesCtrl, required this.experienceCtrl,
    required this.tarifCtrl, required this.isFreelance,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(children: [
          Expanded(child: _Field(prenomCtrl, 'Prénom', Icons.person_outline)),
          const SizedBox(width: 12),
          Expanded(child: _Field(nomCtrl, 'Nom', Icons.person_outline)),
        ]),
        const SizedBox(height: 14),
        _Field(telCtrl, 'Téléphone', Icons.phone_outlined, type: TextInputType.phone),
        const SizedBox(height: 14),
        _Field(villeCtrl, 'Ville', Icons.location_on_outlined),
        if (isFreelance) ...[
          const SizedBox(height: 14),
          _Field(titreCtrl, 'Titre professionnel', Icons.work_outline),
          const SizedBox(height: 14),
          _Field(bioCtrl, 'Bio', Icons.info_outline, maxLines: 3),
          const SizedBox(height: 14),
          _Field(competencesCtrl, 'Compétences', Icons.psychology_outlined, maxLines: 2),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: _Field(experienceCtrl, 'Années d\'exp.', Icons.workspace_premium_outlined, type: TextInputType.number)),
            const SizedBox(width: 12),
            Expanded(child: _Field(tarifCtrl, 'Tarif/h (Ar)', Icons.attach_money, type: TextInputType.number)),
          ]),
        ],
      ],
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final IconData icon;
  final int maxLines;
  final TextInputType type;
  const _Field(this.ctrl, this.label, this.icon, {this.maxLines = 1, this.type = TextInputType.text});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: type,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon), alignLabelWithHint: maxLines > 1),
    );
  }
}
