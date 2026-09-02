import 'package:flutter/material.dart';

import '../../data/repositories/task_repository.dart';
import 'monthly_report_screen.dart';

class YearlyReportScreen extends StatefulWidget {
  const YearlyReportScreen({super.key});

  @override
  State<YearlyReportScreen> createState() => _YearlyReportScreenState();
}

class _YearlyReportScreenState extends State<YearlyReportScreen> {
  final _taskRepository = TaskRepository();
  int _year = DateTime.now().year;
  List<Map<String, ({int completed, int total})>>? _monthSummaries; // index 0..11

  static const _monthNames = [
    'Yanvar', 'Fevral', 'Mart', 'Aprel', 'May', 'Iyun',
    'Iyul', 'Avgust', 'Sentabr', 'Oktabr', 'Noyabr', 'Dekabr',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _monthSummaries = null);
    final results = await Future.wait(
      List.generate(12, (i) => _taskRepository.getMonthlyCompletionSummary(DateTime(_year, i + 1, 1))),
    );
    if (mounted) setState(() => _monthSummaries = results);
  }

  void _changeYear(int delta) {
    setState(() => _year += delta);
    _load();
  }

  double _monthAverage(int monthIndex) {
    final summary = _monthSummaries![monthIndex];
    final withPlans = summary.values.where((e) => e.total > 0).toList();
    if (withPlans.isEmpty) return -1;
    final totalPct = withPlans.map((e) => e.completed / e.total).reduce((a, b) => a + b);
    return totalPct / withPlans.length;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Yillik ko\'rinish')),
      body: _monthSummaries == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(icon: const Icon(Icons.chevron_left), onPressed: () => _changeYear(-1)),
                    Text('$_year', style: Theme.of(context).textTheme.titleLarge),
                    IconButton(icon: const Icon(Icons.chevron_right), onPressed: () => _changeYear(1)),
                  ],
                ),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: 12,
                  itemBuilder: (context, i) {
                    final avg = _monthAverage(i);
                    return InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => MonthlyReportScreen(initialMonth: DateTime(_year, i + 1, 1))),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Theme.of(context).dividerColor),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_monthNames[i], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 6),
                            Expanded(
                              child: _MiniMonthGrid(
                                year: _year,
                                month: i + 1,
                                summary: _monthSummaries![i],
                                accent: scheme.primary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              avg < 0 ? "Ma'lumot yo'q" : "O'rtacha ${(avg * 100).round()}%",
                              style: TextStyle(fontSize: 10, color: Theme.of(context).hintColor),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
    );
  }
}

/// A tiny, non-interactive dot-grid preview of one month's completion —
/// just for the yearly overview cards, not meant to be tapped per-day.
class _MiniMonthGrid extends StatelessWidget {
  final int year;
  final int month;
  final Map<String, ({int completed, int total})> summary;
  final Color accent;
  const _MiniMonthGrid({required this.year, required this.month, required this.summary, required this.accent});

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final leadingBlanks = (DateTime(year, month, 1).weekday - 1) % 7;

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, mainAxisSpacing: 1, crossAxisSpacing: 1),
      itemCount: leadingBlanks + daysInMonth,
      itemBuilder: (context, i) {
        if (i < leadingBlanks) return const SizedBox.shrink();
        final dayNum = i - leadingBlanks + 1;
        final key =
            '$year-${month.toString().padLeft(2, '0')}-${dayNum.toString().padLeft(2, '0')}';
        final entry = summary[key];
        final pct = (entry == null || entry.total == 0) ? -1.0 : entry.completed / entry.total;
        return Container(
          margin: const EdgeInsets.all(0.5),
          decoration: BoxDecoration(
            color: pct < 0 ? Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.25) : Color.lerp(accent.withOpacity(0.12), accent, pct),
            borderRadius: BorderRadius.circular(1.5),
          ),
        );
      },
    );
  }
}
