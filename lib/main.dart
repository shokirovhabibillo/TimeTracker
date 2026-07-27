import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'providers/settings_provider.dart';
import 'providers/task_provider.dart';
import 'providers/usage_provider.dart';
import 'screens/home/home_screen.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.init();
  runApp(const FocusLifeTrackerApp());
}

class FocusLifeTrackerApp extends StatelessWidget {
  const FocusLifeTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()..load()),
        ChangeNotifierProvider(create: (_) => TaskProvider()..loadTasksForSelectedDay()),
        ChangeNotifierProvider(create: (_) => UsageProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: 'Focus & Life Tracker',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.of(settings.themeType),
            home: settings.isLoading
                ? const _SplashScreen()
                : const HomeScreen(),
          );
        },
      ),
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
