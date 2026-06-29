import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/constants.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../widgets/user_avatar.dart';

class FreelanceListScreen extends StatefulWidget {
  const FreelanceListScreen({super.key});

  @override
  State<FreelanceListScreen> createState() => _FreelanceListScreenState();
}

class _FreelanceListScreenState extends State<FreelanceListScreen> {
  List<User> _freelances = [];
  bool _loading = true;
  final _searchCtrl = TextEditingController();
  String? _disponibilite;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load({String? search, String? disponibilite}) async {
    setState(() => _loading = true);
    try {
      final data = await ApiService.getFreelances(search: search, disponibilite: disponibilite);
      final List<dynamic> results = data['results'] ?? data;
      if (mounted) {
        setState(() {
          _freelances = results.map((u) => User.fromJson(u)).toList();
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Freelances')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Rechercher un freelance...',
                prefixIcon: const Icon(Icons.search, color: AppConstants.textMuted),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppConstants.textMuted),
                        onPressed: () {
                          _searchCtrl.clear();
                          _load();
                          setState(() {});
                        },
                      )
                    : null,
              ),
              onSubmitted: (v) => _load(search: v, disponibilite: _disponibilite),
              onChanged: (v) {
                if (v.isEmpty) _load(disponibilite: _disponibilite);
                setState(() {});
              },
            ),
          ),
          // Filtre disponibilité
          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _FilterChip(label: 'Tous', selected: _disponibilite == null, onTap: () {
                  setState(() => _disponibilite = null);
                  _load(search: _searchCtrl.text);
                }),
                _FilterChip(label: 'Disponible', selected: _disponibilite == 'disponible', onTap: () {
                  setState(() => _disponibilite = 'disponible');
                  _load(search: _searchCtrl.text, disponibilite: 'disponible');
                }),
                _FilterChip(label: 'Partiel', selected: _disponibilite == 'partiel', onTap: () {
                  setState(() => _disponibilite = 'partiel');
                  _load(search: _searchCtrl.text, disponibilite: 'partiel');
                }),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: AppConstants.goldColor))
                : _freelances.isEmpty
                    ? const Center(child: Text('Aucun freelance trouvé', style: TextStyle(color: AppConstants.textMuted)))
                    : RefreshIndicator(
                        color: AppConstants.goldColor,
                        onRefresh: () => _load(search: _searchCtrl.text, disponibilite: _disponibilite),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _freelances.length,
                          itemBuilder: (_, i) => _FreelanceCard(
                            user: _freelances[i],
                            onTap: () => context.push('/chat/${_freelances[i].id}?nom=${Uri.encodeComponent(_freelances[i].nomComplet)}'),
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppConstants.goldColor : AppConstants.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? AppConstants.goldColor : AppConstants.borderColor),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.black : AppConstants.textSecondary,
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _FreelanceCard extends StatelessWidget {
  final User user;
  final VoidCallback onTap;
  const _FreelanceCard({required this.user, required this.onTap});

  Color get _dispoColor {
    switch (user.freelanceProfile?.disponibilite) {
      case 'disponible': return AppConstants.successColor;
      case 'partiel': return AppConstants.warningColor;
      default: return AppConstants.errorColor;
    }
  }

  String get _dispoLabel {
    switch (user.freelanceProfile?.disponibilite) {
      case 'disponible': return 'Disponible';
      case 'partiel': return 'Partiel';
      default: return 'Indisponible';
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = user.freelanceProfile;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppConstants.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppConstants.borderColor),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UserAvatar(photoUrl: user.photo, nom: user.nomComplet, radius: 28, isOnline: user.isOnline),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          user.nomComplet,
                          style: const TextStyle(color: AppConstants.textPrimary, fontWeight: FontWeight.w700, fontSize: 15),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _dispoColor.withAlpha(30),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: _dispoColor.withAlpha(100)),
                        ),
                        child: Text(_dispoLabel, style: TextStyle(color: _dispoColor, fontSize: 10, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  if (profile?.titreProfessionnel.isNotEmpty == true) ...[
                    const SizedBox(height: 2),
                    Text(profile!.titreProfessionnel, style: const TextStyle(color: AppConstants.goldColor, fontSize: 13)),
                  ],
                  const SizedBox(height: 6),
                  if (profile?.bioCourte.isNotEmpty == true)
                    Text(profile!.bioCourte, style: const TextStyle(color: AppConstants.textSecondary, fontSize: 12, height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: AppConstants.goldColor),
                      const SizedBox(width: 4),
                      Text('${profile?.noteMoyenne.toStringAsFixed(1) ?? '0.0'} (${profile?.nbAvis ?? 0})',
                          style: const TextStyle(color: AppConstants.textSecondary, fontSize: 12)),
                      const SizedBox(width: 12),
                      const Icon(Icons.location_on_outlined, size: 12, color: AppConstants.textMuted),
                      const SizedBox(width: 2),
                      Text(user.ville.isNotEmpty ? user.ville : user.pays,
                          style: const TextStyle(color: AppConstants.textMuted, fontSize: 12)),
                      const Spacer(),
                      if (profile?.tarifHoraire != null)
                        Text('${profile!.tarifHoraire!.toStringAsFixed(0)} Ar/h',
                            style: const TextStyle(color: AppConstants.goldColor, fontWeight: FontWeight.w700, fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
