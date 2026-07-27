import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/task_provider.dart';
import '../../providers/timer_provider.dart';
import '../analytics/analytics_screen.dart';
import '../focus/focus_mode_screen.dart';
import '../planner/planner_screen.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  final _screens = const [
    PlannerScreen(),
    FocusModeScreen(),
    AnalyticsScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().refreshActiveTask();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TimerProvider(),
      child: Scaffold(
        body: IndexedStack(index: _index, children: _screens),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.calendar_month), label: 'Reja'),
            NavigationDestination(icon: Icon(Icons.timer_outlined), label: 'Fokus'),
            NavigationDestination(icon: Icon(Icons.insights_outlined), label: 'Tahlil'),
            NavigationDestination(icon: Icon(Icons.settings_outlined), label: 'Sozlama'),
          ],
        ),
      ),
    );
  }
}
