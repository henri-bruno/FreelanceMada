import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../models/mission.dart';
import '../providers/auth_provider.dart';
import '../providers/mission_provider.dart';
import '../widgets/mission_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MissionProvider>().fetchMissions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    final pages = [
      _HomeTab(userName: user?.nom ?? ''),
      const _MissionsTab(),
      const _MessagesTab(),
      const _ProfileTab(),
    ];

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.work_outline), activeIcon: Icon(Icons.work), label: 'Missions'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_outlined), activeIcon: Icon(Icons.chat), label: 'Messages'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  final String userName;
  const _HomeTab({required this.userName});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final missions = context.watch<MissionProvider>();
    final user = auth.user;

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppConstants.primaryColor,
            floating: true,
            title: const Text('FreeLanceMada'),
            actions: [
              IconButton(
                icon: const Icon(Icons.dashboard_outlined, color: AppConstants.goldColor),
                onPressed: () => context.push('/dashboard'),
              ),
              IconButton(
                icon: const Icon(Icons.logout_rounded, color: AppConstants.goldColor),
                onPressed: () async {
                  await context.read<AuthProvider>().logout();
                  if (context.mounted) context.go('/login');
                },
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Greeting
                Text(
                  'Bonjour, ${user?.nom.split(' ').first ?? 'Utilisateur'} 👋',
                  style: const TextStyle(
                    color: AppConstants.textLight,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.isFreelance == true
                      ? 'Trouvez votre prochaine mission'
                      : 'Publiez et gérez vos missions',
                  style: const TextStyle(color: AppConstants.textMuted),
                ),
                const SizedBox(height: 24),
                // Stats cards
                Row(
                  children: [
                    _StatCard(
                      label: 'Missions',
                      value: '${missions.missions.length}',
                      icon: Icons.work_outline,
                    ),
                    const SizedBox(width: 12),
                    _StatCard(
                      label: 'En cours',
                      value: '${missions.missions.where((Mission m) => m.statut == 'en_cours').length}',
                      icon: Icons.pending_outlined,
                      color: AppConstants.goldColor,
                    ),
                    const SizedBox(width: 12),
                    _StatCard(
                      label: 'Terminées',
                      value: '${missions.missions.where((Mission m) => m.statut == 'termine').length}',
                      icon: Icons.check_circle_outline,
                      color: AppConstants.successColor,
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                // Action rapide pour les clients
                if (user?.isClient == true) ...[
                  _QuickActionButton(
                    label: 'Publier une mission',
                    icon: Icons.add_circle_outline,
                    onTap: () => context.push('/missions/create'),
                  ),
                  const SizedBox(height: 28),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Missions récentes',
                      style: TextStyle(
                        color: AppConstants.textLight,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('Voir tout'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (missions.loading)
                  const Center(
                    child: CircularProgressIndicator(color: AppConstants.goldColor),
                  )
                else if (missions.missions.isEmpty)
                  const _EmptyMissions()
                else
                  ...missions.missions.take(5).map((m) {
                    return MissionCard(
                      mission: m,
                      onTap: () => context.push('/mission/${m.id}'),
                    );
                  }),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _MissionsTab extends StatelessWidget {
  const _MissionsTab();

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (_) => MaterialPageRoute(
        builder: (_) => const _MissionsPage(),
      ),
    );
  }
}

class _MissionsPage extends StatelessWidget {
  const _MissionsPage();

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.push('/missions');
    });
    return const Scaffold(backgroundColor: AppConstants.backgroundColor);
  }
}

class _MessagesTab extends StatelessWidget {
  const _MessagesTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(title: const Text('Messages')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_outlined, size: 64, color: AppConstants.goldColor),
            SizedBox(height: 16),
            Text('Sélectionnez une conversation',
                style: TextStyle(color: AppConstants.textMuted)),
          ],
        ),
      ),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.push('/profile');
    });
    return const Scaffold(backgroundColor: AppConstants.backgroundColor);
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    this.color = AppConstants.textMuted,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: AppConstants.cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(label,
                style: const TextStyle(color: AppConstants.textMuted, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppConstants.goldColor.withValues(alpha: 0.2),
              AppConstants.goldColor.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppConstants.goldColor.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppConstants.goldColor.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppConstants.goldColor, size: 22),
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(
                color: AppConstants.goldColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios_rounded,
                color: AppConstants.goldColor, size: 16),
          ],
        ),
      ),
    );
  }
}

class _EmptyMissions extends StatelessWidget {
  const _EmptyMissions();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(Icons.work_off_outlined, size: 60, color: AppConstants.textMuted),
            SizedBox(height: 12),
            Text(
              'Aucune mission disponible',
              style: TextStyle(color: AppConstants.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
