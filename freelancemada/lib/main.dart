import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/mission_provider.dart';
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

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MissionProvider()),
      ],
      child: const FreeLanceMadaApp(),
    ),
  );
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (ctx, state) => const SplashScreen()),
    GoRoute(path: '/login', builder: (ctx, state) => const LoginScreen()),
    GoRoute(path: '/register', builder: (ctx, state) => const RegisterScreen()),
    GoRoute(path: '/home', builder: (ctx, state) => const HomeScreen()),
    GoRoute(path: '/missions', builder: (ctx, state) => const MissionListScreen()),
    GoRoute(path: '/missions/create', builder: (ctx, state) => const CreateMissionScreen()),
    GoRoute(
      path: '/mission/:id',
      builder: (_, state) {
        final id = int.parse(state.pathParameters['id']!);
        return MissionDetailScreen(missionId: id);
      },
    ),
    GoRoute(
      path: '/apply/:id',
      builder: (_, state) {
        final id = int.parse(state.pathParameters['id']!);
        return ApplyScreen(missionId: id);
      },
    ),
    GoRoute(
      path: '/chat/:userId/:userName',
      builder: (_, state) {
        final userId = int.parse(state.pathParameters['userId']!);
        final userName = state.pathParameters['userName']!;
        return ChatScreen(receiverId: userId, receiverNom: userName);
      },
    ),
    GoRoute(path: '/profile', builder: (ctx, state) => const ProfileScreen()),
    GoRoute(path: '/dashboard', builder: (ctx, state) => const DashboardScreen()),
  ],
);

class FreeLanceMadaApp extends StatelessWidget {
  const FreeLanceMadaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'FreeLanceMada',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: _router,
    );
  }
}
