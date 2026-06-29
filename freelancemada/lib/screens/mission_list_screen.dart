import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../providers/auth_provider.dart';
import '../providers/mission_provider.dart';
import '../widgets/mission_card.dart';

class MissionListScreen extends StatefulWidget {
  const MissionListScreen({super.key});

  @override
  State<MissionListScreen> createState() => _MissionListScreenState();
}

class _MissionListScreenState extends State<MissionListScreen> {
  final _searchCtrl = TextEditingController();
  String _selectedStatut = '';
  String? _selectedCategorie;

  final _filters = [
    ('', 'Toutes'),
    ('en_attente', 'En attente'),
    ('en_cours', 'En cours'),
    ('termine', 'Terminées'),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MissionProvider>().loadMissions();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _search() {
    context.read<MissionProvider>().loadMissions(
      search: _searchCtrl.text,
      statut: _selectedStatut.isEmpty ? null : _selectedStatut,
      categorie: _selectedCategorie,
    );
  }

  @override
  Widget build(BuildContext context) {
    final missions = context.watch<MissionProvider>();
    final user = context.read<AuthProvider>().user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Missions'),
      ),
      floatingActionButton: user?.isClient == true
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/missions/create'),
              backgroundColor: AppConstants.goldColor,
              foregroundColor: Colors.black,
              icon: const Icon(Icons.add),
              label: const Text('Publier', style: TextStyle(fontWeight: FontWeight.bold)),
            )
          : null,
      body: Column(
        children: [
          // Recherche
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              onSubmitted: (_) => _search(),
              onChanged: (v) { if (v.isEmpty) _search(); },
              decoration: InputDecoration(
                hintText: 'Rechercher une mission...',
                prefixIcon: const Icon(Icons.search, color: AppConstants.textMuted),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(icon: const Icon(Icons.clear, color: AppConstants.textMuted), onPressed: () {
                        _searchCtrl.clear();
                        _search();
                        setState(() {});
                      })
                    : null,
              ),
            ),
          ),
          // Filtres statut
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: _filters.map((f) {
                final selected = _selectedStatut == f.$1;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedStatut = f.$1);
                    _search();
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected ? AppConstants.goldColor : AppConstants.cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: selected ? AppConstants.goldColor : AppConstants.borderColor),
                    ),
                    child: Text(
                      f.$2,
                      style: TextStyle(
                        color: selected ? Colors.black : AppConstants.textSecondary,
                        fontSize: 12,
                        fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          // Liste
          Expanded(
            child: missions.loading && missions.missions.isEmpty
                ? const Center(child: CircularProgressIndicator(color: AppConstants.goldColor))
                : missions.missions.isEmpty
                    ? _EmptyState(isClient: user?.isClient == true, onPublish: () => context.push('/missions/create'))
                    : RefreshIndicator(
                        color: AppConstants.goldColor,
                        onRefresh: () => context.read<MissionProvider>().loadMissions(),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: missions.missions.length,
                          itemBuilder: (_, i) => MissionCard(
                            mission: missions.missions[i],
                            onTap: () => context.push('/missions/${missions.missions[i].id}'),
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool isClient;
  final VoidCallback onPublish;
  const _EmptyState({required this.isClient, required this.onPublish});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.work_off_outlined, size: 72, color: AppConstants.textMuted),
            const SizedBox(height: 16),
            const Text('Aucune mission trouvée', style: TextStyle(color: AppConstants.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(
              isClient ? 'Publiez votre première mission !' : 'Revenez plus tard.',
              style: const TextStyle(color: AppConstants.textMuted),
            ),
            if (isClient) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onPublish,
                icon: const Icon(Icons.add),
                label: const Text('Publier une mission'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
