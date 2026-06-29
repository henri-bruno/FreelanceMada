import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/mission_provider.dart';
import 'providers/service_provider.dart';
import 'providers/notification_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/mission_list_screen.dart';
import 'screens/mission_detail_screen.dart';
import 'screens/apply_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/create_mission_screen.dart';
import 'screens/service_list_screen.dart';
import 'screens/service_detail_screen.dart';
import 'screens/contrats_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/freelance_list_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MissionProvider()),
        ChangeNotifierProvider(create: (_) => ServiceProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: const FreeLanceMadaApp(),
    ),
  );
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (ctx, _) => const SplashScreen()),
    GoRoute(path: '/login', builder: (ctx, _) => const LoginScreen()),
    GoRoute(path: '/register', builder: (ctx, _) => const RegisterScreen()),
    GoRoute(path: '/home', builder: (ctx, _) => const HomeScreen()),

    // Missions
    GoRoute(path: '/missions', builder: (ctx, _) => const MissionListScreen()),
    GoRoute(path: '/missions/create', builder: (ctx, _) => const CreateMissionScreen()),
    GoRoute(
      path: '/missions/:id',
      builder: (_, state) => MissionDetailScreen(missionId: int.parse(state.pathParameters['id']!)),
    ),
    GoRoute(
      path: '/missions/:id/apply',
      builder: (_, state) => ApplyScreen(missionId: int.parse(state.pathParameters['id']!)),
    ),

    // Services
    GoRoute(path: '/services', builder: (ctx, _) => const ServiceListScreen()),
    GoRoute(
      path: '/services/:id',
      builder: (_, state) => ServiceDetailScreen(serviceId: int.parse(state.pathParameters['id']!)),
    ),

    // Freelances
    GoRoute(path: '/freelances', builder: (ctx, _) => const FreelanceListScreen()),

    // Contrats
    GoRoute(path: '/contrats', builder: (ctx, _) => const ContratsScreen()),

    // Chat
    GoRoute(
      path: '/chat/:userId',
      builder: (_, state) => ChatScreen(
        receiverId: int.parse(state.pathParameters['userId']!),
        receiverNom: state.uri.queryParameters['nom'] ?? 'Utilisateur',
      ),
    ),

    // Profil & Dashboard
    GoRoute(path: '/profile', builder: (ctx, _) => const ProfileScreen()),
    GoRoute(path: '/dashboard', builder: (ctx, _) => const DashboardScreen()),

    // Notifications
    GoRoute(path: '/notifications', builder: (ctx, _) => const NotificationsScreen()),
  ],
);

class FreeLanceMadaApp extends StatelessWidget {
  const FreeLanceMadaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'FreeLanceMada',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      routerConfig: _router,
    );
  }
}
