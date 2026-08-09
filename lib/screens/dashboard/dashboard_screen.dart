import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/repositories/activity_time_repository.dart';
import '../../data/repositories/book_repository.dart';
import '../../data/repositories/focus_session_repository.dart';
import '../../data/repositories/idp_repository.dart';
import '../../data/repositories/step_repository.dart';
import '../../providers/task_provider.dart';
import '../../providers/usage_provider.dart';
import '../../widgets/glass_button.dart';
import '../../widgets/striped_percentage_ring.dart';

/// Every key metric on one screen — steps, calories, distance, focus
/// time, reading progress, IDP progress, distraction time. If it
/// doesn't all fit, swipe left/right between pages and scroll up/down
/// within each page (like a smart watch face).
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _stepRepository = StepRepository();
  final _activityRepository = ActivityTimeRepository();
  final _focusRepository = FocusSessionRepository();
  final _bookRepository = BookRepository();
  final _idpRepository = IdpRepository();

  bool _loading = true;
  int _steps = 0;
  double _distanceKm = 0;
  int _calories = 0;
  int _activityMinutes = 0;
  int _focusMinutesToday = 0;
  int _booksFinished = 0;
  double _idpAverage = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final stepLogs = await _stepRepository.getLastDays(1);
    final steps = stepLogs.isNotEmpty ? stepLogs.last.todaySteps : 0;
    final distance = stepLogs.isNotEmpty ? stepLogs.last.todayDistanceMeters / 1000 : 0.0;
    final activitySeconds = await _activityRepository.getSecondsByActivity(DateTime.now());
    final focusSeconds = await _focusRepository.getTotalCompletedSecondsForDay(DateTime.now());
    final books = await _bookRepository.countFinishedBooks();
    final competencies = await _idpRepository.getAllCompetencies();
    final idpAvg = competencies.isEmpty
        ? 0.0
        : competencies.map((c) => c.overallProgress).reduce((a, b) => a + b) / competencies.length;

    if (!mounted) return;
    setState(() {
      _steps = steps;
      _distanceKm = distance;
      _calories = (steps * 0.04).round();
      _activityMinutes = (activitySeconds.values.fold(0, (a, b) => a + b) / 60).round();
      _focusMinutesToday = (focusSeconds / 60).round();
      _booksFinished = books;
      _idpAverage = idpAvg;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final dayProgress = context.watch<TaskProvider>().dayProgress;
    final distractionMinutes = (context.watch<UsageProvider>().totalDistractingSeconds / 60).round();

    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Two pages of cards — swipe left/right between them, like watch faces.
    final page1Cards = <Widget>[
      _MetricCard(icon: Icons.calendar_today, label: 'Bugungi bajarilish',
          value: '${(dayProgress * 100).round()}%', tint: const Color(0xFF22C55E)),
      _MetricCard(icon: Icons.directions_walk, label: 'Qadam', value: '$_steps', tint: const Color(0xFF3B82F6)),
      _MetricCard(icon: Icons.straighten, label: 'Masofa', value: '${_distanceKm.toStringAsFixed(2)} km', tint: const Color(0xFF06B6D4)),
      _MetricCard(icon: Icons.local_fire_department, label: 'Kaloriya', value: '$_calories kcal', tint: const Color(0xFFF59E0B)),
    ];
    final page2Cards = <Widget>[
      _MetricCard(icon: Icons.timer, label: 'Fokus (bugun)', value: '$_focusMinutesToday daq', tint: const Color(0xFF8B5CF6)),
      _MetricCard(icon: Icons.directions_run, label: 'Faollik vaqti', value: '$_activityMinutes daq', tint: const Color(0xFFEC4899)),
      _MetricCard(icon: Icons.menu_book, label: "O'qilgan kitob", value: '$_booksFinished ta', tint: const Color(0xFF10B981)),
      _MetricCard(icon: Icons.trending_up, label: 'IDP rivojlanish', value: '${(_idpAverage * 100).round()}%', tint: const Color(0xFFF97316)),
      _MetricCard(icon: Icons.smartphone, label: 'Chalg\'ituvchi ilovalar', value: '$distractionMinutes daq', tint: const Color(0xFFEF4444)),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0B0D10),
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: const Color(0xFF0B0D10),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: StripedPercentageRing(value: dayProgress, color: const Color(0xFF22C55E), size: 88),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: PageView(
                children: [
                  _DashboardPage(cards: page1Cards),
                  _DashboardPage(cards: page2Cards),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: GlassButton(
                label: 'Yangilash',
                icon: Icons.refresh,
                tint: const Color(0xFF22C55E),
                width: 180,
                onPressed: () {
                  setState(() => _loading = true);
                  _load();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardPage extends StatelessWidget {
  final List<Widget> cards;
  const _DashboardPage({required this.cards});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        alignment: WrapAlignment.center,
        children: cards.map((c) => SizedBox(width: 150, height: 130, child: c)).toList(),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color tint;
  const _MetricCard({required this.icon, required this.label, required this.value, required this.tint});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      tint: tint,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: tint, size: 22),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          Text(label, style: TextStyle(color: tint, fontSize: 11), maxLines: 2, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
