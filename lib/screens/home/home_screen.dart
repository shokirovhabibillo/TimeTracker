import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/settings_provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/timer_provider.dart';
import '../../widgets/morphing_nav_bar.dart';
import '../../widgets/patterned_background.dart';
import '../analytics/analytics_screen.dart';
import '../focus/focus_mode_screen.dart';
import '../more/more_menu_screen.dart';
import '../planner/planner_screen.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  Widget _screenAt(int i) {
    switch (i) {
      case 0:
        return const PlannerScreen();
      case 1:
        return FocusModeScreen(isActive: _index == 1);
      case 2:
        return const AnalyticsScreen();
      case 3:
        return const SettingsScreen();
      default:
        return const MoreMenuScreen();
    }
  }

  static const _items = [
    NavItem(icon: Icons.calendar_month_outlined, selectedIcon: Icons.calendar_month, label: 'Reja'),
    NavItem(icon: Icons.timer_outlined, selectedIcon: Icons.timer, label: 'Fokus'),
    NavItem(icon: Icons.insights_outlined, selectedIcon: Icons.insights, label: 'Tahlil'),
    NavItem(icon: Icons.settings_outlined, selectedIcon: Icons.settings, label: 'Sozlama'),
    NavItem(icon: Icons.apps_outlined, selectedIcon: Icons.apps, label: 'Boshqa'),
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
    final patternName = context.watch<SettingsProvider>().settings.backgroundPattern;
    final pattern = BackgroundPatternType.values.firstWhere(
      (p) => p.name == patternName,
      orElse: () => BackgroundPatternType.none,
    );

    return ChangeNotifierProvider(
      create: (_) => TimerProvider(),
      child: OrientationBuilder(builder: (context, orientation) {
        final isLandscape = orientation == Orientation.landscape;

        // The Focus screen adapts its own internal layout to whatever
        // orientation the device is actually in (see FocusModeScreen) —
        // when it's the active tab in landscape, it takes the full
        // screen and the app-level nav bar is hidden.
        if (isLandscape && _index == 1) {
          return Scaffold(
            body: PatternedBackground(pattern: pattern, child: _screenAt(1)),
          );
        }

        final screens = List.generate(5, _screenAt);

        final nav = MorphingNavBar(
          items: _items,
          selectedIndex: _index,
          onSelected: (i) => setState(() => _index = i),
          axis: isLandscape ? Axis.vertical : Axis.horizontal,
        );

        return Scaffold(
          body: PatternedBackground(
            pattern: pattern,
            child: isLandscape
                ? Row(
                    children: [
                      nav,
                      Expanded(child: IndexedStack(index: _index, children: screens)),
                    ],
                  )
                : Column(
                    children: [
                      Expanded(child: IndexedStack(index: _index, children: screens)),
                      nav,
                    ],
                  ),
          ),
        );
      }),
    );
  }
}
