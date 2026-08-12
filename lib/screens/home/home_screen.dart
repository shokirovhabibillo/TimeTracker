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
import '../onboarding/onboarding_screen.dart';
import '../planner/planner_screen.dart';
import '../settings/settings_screen.dart';
import '../smartwatch/smartwatch_home_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;
  late final PageController _pageController = PageController(initialPage: 0);

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

  void _goToIndex(int i) {
    setState(() => _index = i);
    _pageController.animateToPage(i, duration: const Duration(milliseconds: 260), curve: Curves.easeInOutCubic);
    if (i == 0) context.read<TaskProvider>().loadTasksForSelectedDay();
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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      context.read<TaskProvider>().refreshActiveTask();
      final settings = context.read<SettingsProvider>();
      if (!settings.isLoading && !settings.settings.hasSeenOnboarding && mounted) {
        await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const OnboardingScreen()));
        settings.markOnboardingSeen();
      } else if (settings.isLoading) {
        // Settings may still be loading on cold start — check again shortly.
        await Future.delayed(const Duration(milliseconds: 400));
        if (mounted && !context.read<SettingsProvider>().settings.hasSeenOnboarding) {
          await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const OnboardingScreen()));
          if (mounted) context.read<SettingsProvider>().markOnboardingSeen();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final patternName = settingsProvider.settings.backgroundPattern;
    final pattern = BackgroundPatternType.values.firstWhere(
      (p) => p.name == patternName,
      orElse: () => BackgroundPatternType.none,
    );

    if (settingsProvider.settings.visualizationMode == 'smartwatch') {
      return const SmartwatchHomeScreen();
    }

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
          onSelected: _goToIndex,
          axis: isLandscape ? Axis.vertical : Axis.horizontal,
        );

        final pageView = PageView(
          controller: _pageController,
          onPageChanged: (i) {
            setState(() => _index = i);
            if (i == 0) context.read<TaskProvider>().loadTasksForSelectedDay();
          },
          children: screens,
        );

        return Scaffold(
          extendBody: true,
          body: PatternedBackground(
            pattern: pattern,
            child: isLandscape
                ? Row(
                    children: [
                      nav,
                      Expanded(child: pageView),
                    ],
                  )
                : Stack(
                    children: [
                      Positioned.fill(child: pageView),
                      Positioned(left: 0, right: 0, bottom: 0, child: nav),
                    ],
                  ),
          ),
        );
      }),
    );
  }
}
