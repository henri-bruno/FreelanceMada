import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../providers/auth_provider.dart';
import '../providers/mission_provider.dart';
import '../widgets/mission_card.dart';
import '../widgets/custom_button.dart';

class MissionListScreen extends StatefulWidget {
  const MissionListScreen({super.key});

  @override
  State<MissionListScreen> createState() => _MissionListScreenState();
}

class _MissionListScreenState extends State<MissionListScreen> {
  final _searchCtrl = TextEditingController();
  String _selectedFilter = '';

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
      context.read<MissionProvider>().fetchMissions();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _search() {
    context.read<MissionProvider>().fetchMissions(
      search: _searchCtrl.text,
      statut: _selectedFilter,
    );
  }

  @override
  Widget build(BuildContext context) {
    final missions = context.watch<MissionProvider>();
    final user = context.read<AuthProvider>().user;

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Missions'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppConstants.goldColor),
          onPressed: () => context.pop(),
        ),
      ),
      floatingActionButton: user?.isClient == true
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/missions/create'),
              backgroundColor: AppConstants.goldColor,
              foregroundColor: AppConstants.primaryColor,
              icon: const Icon(Icons.add),
              label: const Text('Nouvelle mission', style: TextStyle(fontWeight: FontWeight.bold)),
            )
          : null,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              style: const TextStyle(color: AppConstants.textLight),
              onSubmitted: (_) => _search(),
              decoration: InputDecoration(
                hintText: 'Rechercher une mission...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.tune, color: AppConstants.goldColor),
                  onPressed: _search,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              scrollDirection: Axis.horizontal,
              children: _filters.map((f) {
                final selected = _selectedFilter == f.$1;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(f.$2),
                    selected: selected,
                    onSelected: (_) {
                      setState(() => _selectedFilter = f.$1);
                      _search();
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: missions.loading
                ? const Center(
                    child: CircularProgressIndicator(color: AppConstants.goldColor),
                  )
                : missions.missions.isEmpty
                    ? _EmptyState(isClient: user?.isClient == true)
                    : RefreshIndicator(
                        color: AppConstants.goldColor,
                        onRefresh: () => context.read<MissionProvider>().fetchMissions(),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: missions.missions.length,
                          itemBuilder: (_, i) => MissionCard(
                            mission: missions.missions[i],
                            onTap: () => context.push('/mission/${missions.missions[i].id}'),
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
  const _EmptyState({required this.isClient});

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
            const Text(
              'Aucune mission trouvée',
              style: TextStyle(color: AppConstants.textLight, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              isClient ? 'Publiez votre première mission !' : 'Revenez plus tard.',
              style: const TextStyle(color: AppConstants.textMuted),
            ),
            if (isClient) ...[
              const SizedBox(height: 24),
              GoldButton(
                label: 'Publier une mission',
                icon: Icons.add,
                width: 220,
                onPressed: () => context.push('/missions/create'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
