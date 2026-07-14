import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'ui/screens/scan_screen.dart';
import 'ui/screens/dashboard_screen.dart';
import 'ui/screens/config_screen.dart';
import 'ui/theme/app_theme.dart';
import 'car/car_pid_sync_provider.dart';

void main() {
  runApp(const ProviderScope(child: ObdApp()));
}

final _router = GoRouter(
  initialLocation: '/scan',
  routes: [
    GoRoute(
      path: '/scan',
      builder: (context, state) => const ScanScreen(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/config',
      builder: (context, state) => const ConfigScreen(),
    ),
  ],
);

class ObdApp extends ConsumerWidget {
  const ObdApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Keeps the car-screen sync alive for the app's lifetime.
    ref.watch(carPidSyncProvider);

    return MaterialApp.router(
      title: 'OBD-II Dashboard',
      theme: AppTheme.darkTheme,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
