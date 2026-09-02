import 'package:flutter/material.dart';

import '../../data/models/lesson_plan_model.dart';
import '../../data/models/step_model.dart';
import '../../data/repositories/activity_time_repository.dart';
import '../../data/repositories/daily_game_repository.dart';
import '../../data/repositories/focus_session_repository.dart';
import '../../data/repositories/lesson_session_repository.dart';
import '../../data/repositories/medicine_repository.dart';
import '../../data/repositories/step_repository.dart';
import '../../data/repositories/task_repository.dart';
import '../../data/repositories/usage_repository.dart';
import '../../services/daily_activity_score.dart';
import 'yearly_report_screen.dart';

class MonthlyReportScreen extends StatefulWidget {
  final DateTime? initialMonth;
  const MonthlyReportScreen({super.key, this.initialMonth});

  @override
  State<MonthlyReportScreen> createState() => _MonthlyReportScreenState();
}

class _MonthlyReportScreenState extends State<MonthlyReportScreen> {
  final _taskRepository = TaskRepository();
  final _usageRepository = UsageRepository();
  final _stepRepository = StepRepository();
  final _activityRepository = ActivityTimeRepository();
  final _medicineRepository = MedicineRepository();
  final _gameRepository = DailyGameRepository();
  final _lessonRepository = LessonSessionRepository();
  final _focusRepository = FocusSessionRepository();

  late DateTime _month;
  Map<String, ({int completed, int total})>? _summary;
  Map<String, DailyActivityScore>? _scores;
  DateTime? _selectedDay;
  int? _selectedDistractingSeconds;
  int _selectedSteps = 0;
  double _selectedDistanceKm = 0;
  int _selectedCalories = 0;
  int _selectedActivityMinutes = 0;
  bool _selectedMedicineTaken = false;
  bool _selectedGamePlayed = false;
  List<String> _selectedLessonDomains = [];
  int _selectedFocusMinutes = 0;
  bool _selectedDetailLoading = false;

  final _scoreService = DailyActivityScoreService();

  static const _weekdayNames = ['Dush', 'Sesh', 'Chor', 'Pay', 'Jum', 'Shan', 'Yak'];

  @override
  void initState() {
    super.initState();
    _month = widget.initialMonth ?? DateTime(DateTime.now().year, DateTime.now().month, 1);
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _summary = null;
      _scores = null;
    });
    final summary = await _taskRepository.getMonthlyCompletionSummary(_month);
    final scores = await _scoreService.getMonthlyScores(_month);
    if (mounted) {
      setState(() {
        _summary = summary;
        _scores = scores;
      });
    }
  }

  String _dateKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// Cell shading now reflects the blended activity score (plan +
  /// steps + focus + medicine), not plan completion alone — a day with
  /// a light plan but lots of walking/focus no longer looks "empty".
  /// Still returns -1 (no-data gray) only when there's truly nothing
  /// recorded that day at all.
  double _pctFor(DateTime day) {
    final score = _scores?[_dateKey(day)];
    if (score == null) return -1;
    final hasAnySignal = score.totalTasks > 0 || score.steps > 0 || score.focusMinutes > 0 || score.medicineTaken;
    if (!hasAnySignal) return -1;
    return score.value / 100;
  }

  Future<void> _selectDay(DateTime day) async {
    setState(() {
      _selectedDay = day;
      _selectedDistractingSeconds = null;
      _selectedDetailLoading = true;
    });

    final results = await Future.wait([
      _usageRepository.getDistractingSecondsForDay(day),
      _stepRepository.getLogForDay(day),
      _activityRepository.getSecondsByActivity(day),
      _medicineRepository.getTakenDoseKeys(day),
      _gameRepository.anyGamePlayedOnDay(day),
      _focusRepository.getTotalCompletedSecondsForDay(day),
      _lessonRepository.getSecondsByDomainForDay(day),
    ]);

    if (!mounted) return;
    final stepLog = results[1] as StepLog;
    final activitySeconds = results[2] as Map<String, int>;
    final takenDoses = results[3] as Set<String>;
    final lessonSeconds = results[6] as Map<String, int>;

    setState(() {
      _selectedDistractingSeconds = results[0] as int;
      _selectedSteps = stepLog.todaySteps;
      _selectedDistanceKm = stepLog.todayDistanceMeters / 1000;
      _selectedCalories = (_selectedSteps * 0.04).round();
      _selectedActivityMinutes = (activitySeconds.values.fold(0, (a, b) => a + b) / 60).round();
      _selectedMedicineTaken = takenDoses.isNotEmpty;
      _selectedGamePlayed = results[4] as bool;
      _selectedFocusMinutes = ((results[5] as int) / 60).round();
      _selectedLessonDomains = lessonSeconds.keys.toList();
      _selectedDetailLoading = false;
    });
  }

  void _changeMonth(int delta) {
    setState(() => _month = DateTime(_month.year, _month.month + delta, 1));
    _load();
  }

  /// Average completion % per weekday across the loaded month — used to
  /// surface "you're usually more/less active on [day]" insights.
  Map<int, List<double>> _weekdayBuckets() {
    final buckets = <int, List<double>>{for (var i = 1; i <= 7; i++) i: []};
    if (_summary == null) return buckets;
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    for (int d = 1; d <= daysInMonth; d++) {
      final day = DateTime(_month.year, _month.month, d);
      final entry = _summary![_dateKey(day)];
      if (entry != null && entry.total > 0) {
        buckets[day.weekday]!.add(entry.completed / entry.total);
      }
    }
    return buckets;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final firstOfMonth = _month;
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    // Monday-first offset for the leading blank cells.
    final leadingBlanks = (firstOfMonth.weekday - 1) % 7;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Oylik hisobot'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_view_month),
            tooltip: "Yillik ko'rinish",
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const YearlyReportScreen()),
            ),
          ),
        ],
      ),
      body: (_summary == null || _scores == null)
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(icon: const Icon(Icons.chevron_left), onPressed: () => _changeMonth(-1)),
                    Text('${_month.month}.${_month.year}', style: Theme.of(context).textTheme.titleMedium),
                    IconButton(icon: const Icon(Icons.chevron_right), onPressed: () => _changeMonth(1)),
                  ],
                ),
                const SizedBox(height: 8),
                _buildInsightBanner(),
                const SizedBox(height: 16),
                Row(
                  children: _weekdayNames
                      .map((w) => Expanded(
                            child: Center(
                                child: Text(w, style: TextStyle(fontSize: 11, color: Theme.of(context).hintColor))),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 4),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7),
                  itemCount: leadingBlanks + daysInMonth,
                  itemBuilder: (context, i) {
                    if (i < leadingBlanks) return const SizedBox.shrink();
                    final dayNum = i - leadingBlanks + 1;
                    final day = DateTime(_month.year, _month.month, dayNum);
                    final pct = _pctFor(day);
                    final isSelected = _selectedDay != null &&
                        _selectedDay!.year == day.year &&
                        _selectedDay!.month == day.month &&
                        _selectedDay!.day == day.day;
                    final isWeekend = day.weekday == DateTime.saturday || day.weekday == DateTime.sunday;

                    Color cellColor;
                    if (pct < 0) {
                      cellColor = Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3);
                    } else {
                      cellColor = Color.lerp(scheme.primary.withOpacity(0.12), scheme.primary, pct)!;
                    }

                    return Padding(
                      padding: const EdgeInsets.all(3),
                      child: InkWell(
                        onTap: () => _selectDay(day),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          decoration: BoxDecoration(
                            color: cellColor,
                            borderRadius: BorderRadius.circular(8),
                            border: isSelected ? Border.all(color: scheme.primary, width: 2) : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '$dayNum',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isWeekend ? FontWeight.bold : FontWeight.normal,
                              color: pct >= 0.5 ? Colors.white : null,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Faollik balli: ', style: TextStyle(fontSize: 10, color: Theme.of(context).hintColor)),
                    Text('Kam', style: TextStyle(fontSize: 10, color: Theme.of(context).hintColor)),
                    const SizedBox(width: 4),
                    ...List.generate(4, (i) {
                      final t = i / 3;
                      return Container(
                        width: 14,
                        height: 14,
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        decoration: BoxDecoration(
                          color: Color.lerp(scheme.primary.withOpacity(0.12), scheme.primary, t),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      );
                    }),
                    const SizedBox(width: 4),
                    Text("Ko'p", style: TextStyle(fontSize: 10, color: Theme.of(context).hintColor)),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    "(reja bajarilishi + qadam + fokus + dori — birlashtirilgan ko'rsatkich)",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 9, color: Theme.of(context).hintColor),
                  ),
                ),
                if (_selectedDay != null) ...[
                  const SizedBox(height: 16),
                  _buildDayDetail(),
                ],
              ],
            ),
    );
  }

  Widget _buildInsightBanner() {
    final buckets = _weekdayBuckets();
    final averages = <int, double>{};
    buckets.forEach((weekday, values) {
      if (values.isNotEmpty) averages[weekday] = values.reduce((a, b) => a + b) / values.length;
    });
    if (averages.isEmpty) return const SizedBox.shrink();

    final best = averages.entries.reduce((a, b) => a.value >= b.value ? a : b);
    final worst = averages.entries.reduce((a, b) => a.value <= b.value ? a : b);
    const names = ['', 'Dushanba', 'Seshanba', 'Chorshanba', 'Payshanba', 'Juma', 'Shanba', 'Yakshanba'];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.trending_up, size: 16, color: Colors.green),
            const SizedBox(width: 6),
            Expanded(
                child: Text('Eng faol kun: ${names[best.key]} (~${(best.value * 100).round()}%)',
                    style: const TextStyle(fontSize: 12))),
          ]),
          const SizedBox(height: 4),
          Row(children: [
            const Icon(Icons.trending_down, size: 16, color: Colors.orange),
            const SizedBox(width: 6),
            Expanded(
                child: Text('Eng sust kun: ${names[worst.key]} (~${(worst.value * 100).round()}%)',
                    style: const TextStyle(fontSize: 12))),
          ]),
        ],
      ),
    );
  }

  Widget _statChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildDayDetail() {
    final day = _selectedDay!;
    final entry = _summary![_dateKey(day)];
    final isWeekend = day.weekday == DateTime.saturday || day.weekday == DateTime.sunday;
    final pct = entry != null && entry.total > 0 ? entry.completed / entry.total : null;

    // Plain-language "why" analysis from the signals we actually have.
    final reasons = <String>[];
    if (entry == null || entry.total == 0) {
      reasons.add(isWeekend ? "Bu kuni reja olinmagan — dam olish kuni bo'lgani sababli bo'lishi mumkin." : "Bu kuni umuman reja olinmagan.");
    } else {
      if (isWeekend) reasons.add("Dam olish kuni edi.");
      if (pct != null && pct < 0.5) {
        if (_selectedDistractingSeconds != null && _selectedDistractingSeconds! > 1800) {
          final mins = (_selectedDistractingSeconds! / 60).round();
          reasons.add("Chalg'ituvchi ilovalarga $mins daqiqa sarflangan — bu bajarilishga ta'sir qilgan bo'lishi mumkin.");
        }
        if (reasons.isEmpty) reasons.add("Sabab aniq emas — vazifalar rejalashtirilgan, lekin ko'pchiligi bajarilmagan.");
      } else if (pct != null && pct >= 0.8) {
        reasons.add("Yaxshi natija — rejalashtirilgan vazifalarning aksariyati bajarilgan.");
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${day.day}.${day.month}.${day.year}', style: const TextStyle(fontWeight: FontWeight.bold)),
              if (_scores?[_dateKey(day)] != null)
                Text('Ball: ${_scores![_dateKey(day)]!.value.round()}/100',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
            ],
          ),
          const SizedBox(height: 6),
          if (entry != null && entry.total > 0)
            Text('${entry.completed}/${entry.total} vazifa bajarilgan (${((pct ?? 0) * 100).round()}%)')
          else
            const Text("Bu kun uchun reja topilmadi."),
          if (_selectedDistractingSeconds != null && _selectedDistractingSeconds! > 0) ...[
            const SizedBox(height: 4),
            Text("Chalg'ituvchi ilovalar: ${(_selectedDistractingSeconds! / 60).round()} daqiqa",
                style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor)),
          ],
          if (_selectedDetailLoading) ...[
            const SizedBox(height: 10),
            const Center(child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))),
          ] else ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              runSpacing: 6,
              children: [
                if (_selectedSteps > 0)
                  _statChip(Icons.directions_walk, '$_selectedSteps qadam'),
                if (_selectedDistanceKm > 0)
                  _statChip(Icons.straighten, '${_selectedDistanceKm.toStringAsFixed(2)} km'),
                if (_selectedCalories > 0)
                  _statChip(Icons.local_fire_department, '$_selectedCalories kkal'),
                if (_selectedActivityMinutes > 0)
                  _statChip(Icons.directions_run, '$_selectedActivityMinutes daq faollik'),
                if (_selectedFocusMinutes > 0)
                  _statChip(Icons.timer, '$_selectedFocusMinutes daq fokus'),
              ],
            ),
            if (_selectedMedicineTaken || _selectedGamePlayed || _selectedLessonDomains.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  if (_selectedMedicineTaken)
                    Chip(
                      avatar: const Icon(Icons.medication, size: 14),
                      label: const Text('Dori ichilgan', style: TextStyle(fontSize: 11)),
                      visualDensity: VisualDensity.compact,
                    ),
                  if (_selectedGamePlayed)
                    Chip(
                      avatar: const Icon(Icons.videogame_asset, size: 14),
                      label: const Text("O'yin o'ynalgan", style: TextStyle(fontSize: 11)),
                      visualDensity: VisualDensity.compact,
                    ),
                  ..._selectedLessonDomains.map((d) => Chip(
                        avatar: const Icon(Icons.fitness_center, size: 14),
                        label: Text(PlanDomain.label(d), style: const TextStyle(fontSize: 11)),
                        visualDensity: VisualDensity.compact,
                      )),
                ],
              ),
            ],
          ],
          if (reasons.isNotEmpty) ...[
            const SizedBox(height: 10),
            ...reasons.map((r) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• '),
                      Expanded(child: Text(r, style: const TextStyle(fontSize: 12))),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }
}
