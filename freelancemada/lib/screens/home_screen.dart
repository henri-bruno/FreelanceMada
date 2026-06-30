import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../providers/auth_provider.dart';
import '../providers/mission_provider.dart';
import '../providers/notification_provider.dart';
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
      context.read<MissionProvider>().loadMissions();
      context.read<NotificationProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final nbNotifs = context.watch<NotificationProvider>().unreadCount;

    final pages = <Widget>[
      _HomeTab(user: user),
      const _ExploreTab(),
      const _MessagesTab(),
      const _ProfileTab(),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppConstants.borderColor)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          items: [
            const BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Accueil'),
            const BottomNavigationBarItem(icon: Icon(Icons.explore_outlined), activeIcon: Icon(Icons.explore), label: 'Explorer'),
            const BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), activeIcon: Icon(Icons.chat_bubble), label: 'Messages'),
            BottomNavigationBarItem(
              icon: Stack(
                children: [
                  const Icon(Icons.person_outline),
                  if (nbNotifs > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(color: AppConstants.errorColor, shape: BoxShape.circle),
                      ),
                    ),
                ],
              ),
              activeIcon: const Icon(Icons.person),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}

// ── Onglet Accueil ─────────────────────────────────────────────────────────

class _HomeTab extends StatelessWidget {
  final dynamic user;
  const _HomeTab({required this.user});

  @override
  Widget build(BuildContext context) {
    final missions = context.watch<MissionProvider>();

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppConstants.primaryColor,
            floating: true,
            titleSpacing: 20,
            title: Row(
              children: [
                Image.asset('assets/images/logo.png', width: 32, height: 32),
                const SizedBox(width: 10),
                const Text('FreeLanceMada',
                    style: TextStyle(color: AppConstants.goldColor, fontWeight: FontWeight.w800, fontSize: 18)),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () => context.push('/notifications'),
              ),
              IconButton(
                icon: const Icon(Icons.dashboard_outlined),
                onPressed: () => context.push('/dashboard'),
              ),
              const SizedBox(width: 8),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 80),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Salutation
                RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                    children: [
                      const TextSpan(text: 'Bonjour, ', style: TextStyle(color: AppConstants.textPrimary)),
                      TextSpan(
                        text: '${user?.nom?.split(' ').first ?? 'Utilisateur'} 👋',
                        style: const TextStyle(color: AppConstants.goldColor),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.isFreelance == true
                      ? 'Trouvez votre prochaine mission ou proposez vos services.'
                      : 'Publiez des missions et trouvez les meilleurs freelances.',
                  style: const TextStyle(color: AppConstants.textSecondary, height: 1.5),
                ),
                const SizedBox(height: 24),

                // Actions rapides
                Row(
                  children: [
                    Expanded(child: _QuickBtn(
                      icon: Icons.work_outline,
                      label: 'Missions',
                      onTap: () => context.push('/missions'),
                    )),
                    const SizedBox(width: 10),
                    Expanded(child: _QuickBtn(
                      icon: Icons.star_outline,
                      label: 'Services',
                      onTap: () => context.push('/services'),
                    )),
                    const SizedBox(width: 10),
                    Expanded(child: _QuickBtn(
                      icon: Icons.people_outline,
                      label: 'Freelances',
                      onTap: () => context.push('/freelances'),
                    )),
                    const SizedBox(width: 10),
                    Expanded(child: _QuickBtn(
                      icon: Icons.description_outlined,
                      label: 'Contrats',
                      onTap: () => context.push('/contrats'),
                    )),
                  ],
                ),
                const SizedBox(height: 28),

                // CTA Client
                if (user?.isClient == true) ...[
                  _PublishBanner(onTap: () => context.push('/missions/create')),
                  const SizedBox(height: 28),
                ],

                // CTA Freelance
                if (user?.isFreelance == true) ...[
                  _FreelanceBanner(
                    onMissions: () => context.push('/missions'),
                    onServices: () => context.push('/services/create'),
                  ),
                  const SizedBox(height: 28),
                ],

                // Missions récentes
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Missions disponibles',
                        style: TextStyle(color: AppConstants.textPrimary, fontSize: 17, fontWeight: FontWeight.w700)),
                    TextButton(
                      onPressed: () => context.push('/missions'),
                      child: const Text('Voir tout'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (missions.loading && missions.missions.isEmpty)
                  const Center(child: CircularProgressIndicator(color: AppConstants.goldColor))
                else if (missions.missions.isEmpty)
                  _Empty('Aucune mission disponible', Icons.work_off_outlined)
                else
                  ...missions.missions.take(4).map((m) => MissionCard(
                    mission: m,
                    onTap: () => context.push('/missions/${m.id}'),
                  )),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Onglet Explorer ────────────────────────────────────────────────────────

class _ExploreTab extends StatelessWidget {
  const _ExploreTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Explorer')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Catégories', style: TextStyle(color: AppConstants.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.1,
              ),
              itemCount: AppConstants.categories.length,
              itemBuilder: (_, i) {
                final cat = AppConstants.categories[i];
                return GestureDetector(
                  onTap: () => context.push('/missions?categorie=${cat['nom']}'),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppConstants.cardColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppConstants.borderColor),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.work_outline, color: AppConstants.goldColor, size: 28),
                        const SizedBox(height: 6),
                        Text(
                          cat['nom']!,
                          style: const TextStyle(color: AppConstants.textSecondary, fontSize: 11),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ── Onglet Messages ────────────────────────────────────────────────────────

class _MessagesTab extends StatelessWidget {
  const _MessagesTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 64, color: AppConstants.textMuted),
            SizedBox(height: 16),
            Text('Vos conversations apparaîtront ici', style: TextStyle(color: AppConstants.textMuted)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/freelances'),
        backgroundColor: AppConstants.goldColor,
        foregroundColor: Colors.black,
        child: const Icon(Icons.edit),
      ),
    );
  }
}

// ── Onglet Profil ──────────────────────────────────────────────────────────

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _MenuItem(Icons.person_outline, 'Mon Profil', () => context.push('/profile')),
          _MenuItem(Icons.dashboard_outlined, 'Dashboard', () => context.push('/dashboard')),
          _MenuItem(Icons.description_outlined, 'Mes Contrats', () => context.push('/contrats')),
          _MenuItem(Icons.notifications_outlined, 'Notifications', () => context.push('/notifications')),
          _MenuItem(Icons.star_outlined, 'Mes Services', () => context.push('/services?mine=1')),
          _MenuItem(Icons.work_outline, 'Mes Missions', () => context.push('/missions?mine=1')),
        ],
      ),
    );
  }
}

// ── Widgets helpers ────────────────────────────────────────────────────────

class _QuickBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickBtn({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppConstants.cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppConstants.borderColor),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppConstants.goldColor, size: 22),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: AppConstants.textSecondary, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _PublishBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _PublishBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppConstants.goldColor.withAlpha(40), AppConstants.goldColor.withAlpha(10)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppConstants.goldColor.withAlpha(100)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppConstants.goldColor.withAlpha(40),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.add_circle_outline, color: AppConstants.goldColor, size: 24),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Publier une mission', style: TextStyle(color: AppConstants.goldColor, fontWeight: FontWeight.w700, fontSize: 15)),
                  Text('Trouvez le freelance idéal', style: TextStyle(color: AppConstants.textMuted, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: AppConstants.goldColor, size: 14),
          ],
        ),
      ),
    );
  }
}

class _FreelanceBanner extends StatelessWidget {
  final VoidCallback onMissions;
  final VoidCallback onServices;
  const _FreelanceBanner({required this.onMissions, required this.onServices});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _BannerBtn(
          icon: Icons.search,
          label: 'Trouver des missions',
          onTap: onMissions,
        )),
        const SizedBox(width: 10),
        Expanded(child: _BannerBtn(
          icon: Icons.add,
          label: 'Créer un service',
          onTap: onServices,
        )),
      ],
    );
  }
}

class _BannerBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _BannerBtn({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
        decoration: BoxDecoration(
          color: AppConstants.cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppConstants.borderColor),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppConstants.goldColor, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(label, style: const TextStyle(color: AppConstants.textSecondary, fontSize: 12))),
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _MenuItem(this.icon, this.label, this.onTap);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppConstants.goldColor),
      title: Text(label, style: const TextStyle(color: AppConstants.textPrimary)),
      trailing: const Icon(Icons.chevron_right, color: AppConstants.textMuted),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
    );
  }
}

class _Empty extends StatelessWidget {
  final String message;
  final IconData icon;
  const _Empty(this.message, this.icon);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(icon, size: 56, color: AppConstants.textMuted),
          const SizedBox(height: 12),
          Text(message, style: const TextStyle(color: AppConstants.textMuted)),
        ],
      ),
    );
  }
}
