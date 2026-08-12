import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/timer_provider.dart';
import '../analytics/analytics_screen.dart';
import '../bodybuilding/trapezius_home_screen.dart';
import '../counter/counter_screen.dart';
import '../dashboard/dashboard_screen.dart';
import '../family/family_home_screen.dart';
import '../games/games_hub_screen.dart';
import '../focus/focus_mode_screen.dart';
import '../idp/idp_list_screen.dart';
import '../medicine/medication_home_screen.dart';
import '../news/news_contact_screen.dart';
import '../projects/project_list_screen.dart';
import '../planner/planner_screen.dart';
import '../reading/reading_home_screen.dart';
import '../settings/settings_screen.dart';
import '../steps/step_home_screen.dart';
import '../street_workout/street_workout_home_screen.dart';
import '../study/study_home_screen.dart';
import '../teacher/sport_home_screen.dart';
import '../teacher/teacher_home_screen.dart';
import '../warmup/warmup_home_screen.dart';
import '../worship/worship_home_screen.dart';

/// Every app function as a freely-draggable icon bubble on a pannable
/// canvas — swipe in any direction to browse, like an Apple Watch home
/// screen. An alternative to the normal tab-bar navigation, toggled in
/// Settings ("Smartwatch" visualization mode).
class SmartwatchHomeScreen extends StatelessWidget {
  const SmartwatchHomeScreen({super.key});

  static const _bubbles = <({IconData icon, String label, Color color, WidgetBuilder builder})>[
    (icon: Icons.calendar_month, label: 'Reja', color: Color(0xFF22C55E), builder: _plannerBuilder),
    (icon: Icons.timer, label: 'Fokus', color: Color(0xFF3B82F6), builder: _focusBuilder),
    (icon: Icons.insights, label: 'Tahlil', color: Color(0xFF8B5CF6), builder: _analyticsBuilder),
    (icon: Icons.settings, label: 'Sozlama', color: Color(0xFF64748B), builder: _settingsBuilder),
    (icon: Icons.dashboard_customize, label: 'Dashboard', color: Color(0xFFF59E0B), builder: _dashboardBuilder),
    (icon: Icons.school, label: "O'qituvchi", color: Color(0xFF06B6D4), builder: _teacherBuilder),
    (icon: Icons.fitness_center, label: 'Sport', color: Color(0xFFEC4899), builder: _sportBuilder),
    (icon: Icons.accessibility_new, label: 'Trapetsiya', color: Color(0xFFEF4444), builder: _trapeziusBuilder),
    (icon: Icons.sports_gymnastics, label: 'Street Workout', color: Color(0xFF10B981), builder: _streetWorkoutBuilder),
    (icon: Icons.whatshot, label: 'Badantarbiya', color: Color(0xFFF97316), builder: _warmupBuilder),
    (icon: Icons.menu_book, label: "O'qish", color: Color(0xFF6366F1), builder: _studyBuilder),
    (icon: Icons.mosque, label: 'Ibodat', color: Color(0xFF14B8A6), builder: _worshipBuilder),
    (icon: Icons.pin, label: 'Sanoq', color: Color(0xFFA855F7), builder: _counterBuilder),
    (icon: Icons.trending_up, label: 'IDP', color: Color(0xFFF43F5E), builder: _idpBuilder),
    (icon: Icons.directions_walk, label: 'Faoliyat', color: Color(0xFF0EA5E9), builder: _stepsBuilder),
    (icon: Icons.chrome_reader_mode, label: "O'qish rejimi", color: Color(0xFF84CC16), builder: _readingBuilder),
    (icon: Icons.family_restroom, label: 'Ota-ona/Farzand', color: Color(0xFFD946EF), builder: _familyBuilder),
    (icon: Icons.campaign, label: 'Yangiliklar', color: Color(0xFF78716C), builder: _newsBuilder),
    (icon: Icons.medication, label: 'Dori qabul qilish', color: Color(0xFF16A34A), builder: _medicationBuilder),
    (icon: Icons.dashboard, label: 'Loyihalar', color: Color(0xFF2563EB), builder: _projectsBuilder),
    (icon: Icons.videogame_asset, label: "Kunlik o'yinlar", color: Color(0xFFF59E0B), builder: _gamesBuilder),
  ];

  static Widget _plannerBuilder(BuildContext c) => const PlannerScreen();
  static Widget _focusBuilder(BuildContext c) =>
      ChangeNotifierProvider(create: (_) => TimerProvider(), child: const FocusModeScreen());
  static Widget _analyticsBuilder(BuildContext c) => const AnalyticsScreen();
  static Widget _settingsBuilder(BuildContext c) => const SettingsScreen();
  static Widget _dashboardBuilder(BuildContext c) => const DashboardScreen();
  static Widget _teacherBuilder(BuildContext c) => const TeacherHomeScreen();
  static Widget _sportBuilder(BuildContext c) => const SportHomeScreen();
  static Widget _trapeziusBuilder(BuildContext c) => const TrapeziusHomeScreen();
  static Widget _streetWorkoutBuilder(BuildContext c) => const StreetWorkoutHomeScreen();
  static Widget _warmupBuilder(BuildContext c) => const WarmupHomeScreen();
  static Widget _studyBuilder(BuildContext c) => const StudyHomeScreen();
  static Widget _worshipBuilder(BuildContext c) => const WorshipHomeScreen();
  static Widget _counterBuilder(BuildContext c) => const CounterScreen();
  static Widget _idpBuilder(BuildContext c) => const IdpListScreen();
  static Widget _stepsBuilder(BuildContext c) => const StepHomeScreen();
  static Widget _readingBuilder(BuildContext c) => const ReadingHomeScreen();
  static Widget _familyBuilder(BuildContext c) => const FamilyHomeScreen();
  static Widget _newsBuilder(BuildContext c) => const NewsContactScreen();
  static Widget _medicationBuilder(BuildContext c) => const MedicationHomeScreen();
  static Widget _projectsBuilder(BuildContext c) => const ProjectListScreen();
  static Widget _gamesBuilder(BuildContext c) => const GamesHubScreen();

  @override
  Widget build(BuildContext context) {
    // A 5-column virtual grid, laid out on a canvas larger than the
    // screen so InteractiveViewer can pan it freely in every direction.
    const columns = 5;
    const bubbleSize = 84.0;
    const spacing = 18.0;
    final rows = (_bubbles.length / columns).ceil();
    final canvasWidth = columns * (bubbleSize + spacing) + spacing;
    final canvasHeight = rows * (bubbleSize + spacing) + spacing;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: InteractiveViewer(
          minScale: 0.6,
          maxScale: 2.5,
          boundaryMargin: const EdgeInsets.all(120),
          child: SizedBox(
            width: canvasWidth,
            height: canvasHeight,
            child: Stack(
              children: [
                for (var i = 0; i < _bubbles.length; i++)
                  Positioned(
                    left: spacing + (i % columns) * (bubbleSize + spacing),
                    top: spacing + (i ~/ columns) * (bubbleSize + spacing),
                    width: bubbleSize,
                    height: bubbleSize,
                    child: _Bubble(item: _bubbles[i]),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final ({IconData icon, String label, Color color, WidgetBuilder builder}) item;
  const _Bubble({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: item.builder)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [item.color, item.color.withOpacity(0.6)],
              ),
              boxShadow: [BoxShadow(color: item.color.withOpacity(0.5), blurRadius: 10)],
            ),
            child: Icon(item.icon, color: Colors.white, size: 26),
          ),
          const SizedBox(height: 4),
          Text(
            item.label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
