import 'package:flutter/material.dart';

import '../../l10n/app_text.dart';
import '../counter/counter_screen.dart';
import '../dashboard/dashboard_screen.dart';
import '../family/family_home_screen.dart';
import '../games/games_hub_screen.dart';
import '../idp/idp_list_screen.dart';
import '../medicine/medication_home_screen.dart';
import '../news/news_contact_screen.dart';
import '../projects/project_list_screen.dart';
import '../strategy/strategy_level_screen.dart';
import '../onboarding/onboarding_screen.dart';
import '../reading/reading_home_screen.dart';
import '../steps/step_home_screen.dart';
import '../study/study_home_screen.dart';
import '../teacher/sport_home_screen.dart';
import '../teacher/teacher_home_screen.dart';
import '../worship/worship_home_screen.dart';

class MoreMenuScreen extends StatelessWidget {
  const MoreMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <({IconData icon, String label, WidgetBuilder builder})>[
      (icon: Icons.dashboard_customize, label: appText(context, 'moreDashboard'), builder: (_) => const DashboardScreen()),
      (icon: Icons.school_outlined, label: appText(context, 'moreTeacher'), builder: (_) => const TeacherHomeScreen()),
      (icon: Icons.fitness_center, label: appText(context, 'moreSport'), builder: (_) => const SportHomeScreen()),
      (icon: Icons.menu_book_outlined, label: appText(context, 'moreStudy'), builder: (_) => const StudyHomeScreen()),
      (icon: Icons.mosque_outlined, label: appText(context, 'moreWorship'), builder: (_) => const WorshipHomeScreen()),
      (icon: Icons.pin_outlined, label: appText(context, 'moreCounter'), builder: (_) => const CounterScreen()),
      (icon: Icons.trending_up, label: appText(context, 'moreIdp'), builder: (_) => const IdpListScreen()),
      (icon: Icons.family_restroom, label: appText(context, 'moreFamily'), builder: (_) => const FamilyHomeScreen()),
      (icon: Icons.medication_outlined, label: appText(context, 'moreMedicine'), builder: (_) => const MedicationHomeScreen()),
      (icon: Icons.dashboard, label: appText(context, 'moreProjects'), builder: (_) => const ProjectListScreen()),
      (icon: Icons.flag_circle, label: appText(context, 'moreStrategy'), builder: (_) => const StrategyLevelScreen(parentId: null, level: 'asr', parentTitle: 'Umringiz strategiyasi')),
      (icon: Icons.videogame_asset_outlined, label: appText(context, 'moreGames'), builder: (_) => const GamesHubScreen()),
      (icon: Icons.directions_walk, label: appText(context, 'moreSteps'), builder: (_) => const StepHomeScreen()),
      (icon: Icons.chrome_reader_mode_outlined, label: appText(context, 'moreReading'), builder: (_) => const ReadingHomeScreen()),
      (icon: Icons.campaign_outlined, label: appText(context, 'moreNews'), builder: (_) => const NewsContactScreen()),
      (icon: Icons.help_outline, label: appText(context, 'moreHelp'), builder: (_) => const OnboardingScreen()),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(appText(context, 'moreTitle'))),
      body: GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.1,
        ),
        itemCount: items.length,
        itemBuilder: (context, i) {
          final item = items[i];
          return Card(
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: item.builder)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(item.icon, size: 36, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(height: 10),
                    Text(item.label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
