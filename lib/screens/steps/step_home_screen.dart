import 'package:pedometer/pedometer.dart';
import 'package:flutter/material.dart';

import '../../data/models/activity_log_model.dart';
import '../../data/models/step_model.dart';
import '../../data/repositories/activity_time_repository.dart';
import '../../data/repositories/step_repository.dart';

class StepHomeScreen extends StatefulWidget {
  const StepHomeScreen({super.key});

  @override
  State<StepHomeScreen> createState() => _StepHomeScreenState();
}

class _StepHomeScreenState extends State<StepHomeScreen> {
  final _stepRepository = StepRepository();
  final _activityRepository = ActivityTimeRepository();
  StepLog? _log;
  List<StepLog> _weekLogs = [];
  Map<String, int> _activitySeconds = {};
  String? _error;

  static const int _stepGoal = 6000;
  static const int _activityMinuteGoal = 90;

  @override
  void initState() {
    super.initState();
    _listen();
    _loadWeek();
    _loadActivity();
  }

  void _listen() {
    Pedometer.stepCountStream.listen(_onStepCount).onError((e) {
      setState(() => _error = "Qadam sensori mavjud emas yoki ruxsat berilmagan.");
    });
  }

  Future<void> _onStepCount(StepCount event) async {
    final log = await _stepRepository.getOrCreateTodayLog(event.steps);
    if (mounted) setState(() => _log = log);
    _loadWeek();
  }

  Future<void> _loadWeek() async {
    final logs = await _stepRepository.getLastDays(7);
    if (mounted) setState(() => _weekLogs = logs);
  }

  Future<void> _loadActivity() async {
    final map = await _activityRepository.getSecondsByActivity(DateTime.now());
    if (mounted) setState(() => _activitySeconds = map);
  }

  @override
  Widget build(BuildContext context) {
    final steps = _log?.todaySteps ?? 0;
    final walkKm = (_log?.todayDistanceMeters ?? 0) / 1000;
    final calories = (steps * 0.04).round();
    final activityMinutes = (_activitySeconds.values.fold(0, (a, b) => a + b) / 60).round();

    final cyclingKm =
        (DailyActivityLog(date: '', secondsByActivity: _activitySeconds)).distanceForKm(AppActivityType.cycling);
    final vehicleKm =
        (DailyActivityLog(date: '', secondsByActivity: _activitySeconds)).distanceForKm(AppActivityType.vehicle);

    final stepProgress = (steps / _stepGoal).clamp(0.0, 1.0);
    final activityProgress = (activityMinutes / _activityMinuteGoal).clamp(0.0, 1.0);
    final calorieProgress = (calories / 300).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: const Color(0xFF0F1115),
      appBar: AppBar(
        title: const Text('Faoliyat'),
        backgroundColor: const Color(0xFF0F1115),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.redAccent)),
            ),
          if (_error == null && steps == 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(10)),
                child: const Text(
                  "Qadam hali 0 ko'rinsa: ba'zi telefonlarda (masalan Xiaomi/MIUI) "
                  "batareya tejash rejimi fon sensorlarini cheklaydi. Sozlamalar → "
                  "Ilovalar → Focus & Life Tracker → Batareya → \"Cheklovsiz\" qiling.",
                  style: TextStyle(fontSize: 11, color: Colors.white70),
                ),
              ),
            ),
          const Text('Segodnya', style: TextStyle(color: Colors.white54, fontSize: 12)),
          const SizedBox(height: 8),
          // Weekly mini-view — 7 small ring previews, Monday first.
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(_weekLogs.length, (i) {
              final isToday = i == _weekLogs.length - 1;
              final progress = (_weekLogs[i].todaySteps / _stepGoal).clamp(0.0, 1.0);
              const dayLetters = ['D', 'S', 'C', 'P', 'J', 'S', 'Y'];
              return Column(
                children: [
                  Text(dayLetters[i % 7], style: const TextStyle(color: Colors.white38, fontSize: 11)),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: 32,
                    height: 32,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 3,
                          backgroundColor: Colors.white12,
                          valueColor: AlwaysStoppedAnimation(isToday ? const Color(0xFF9BE93B) : Colors.white38),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
          ),
          const SizedBox(height: 24),
          // Triple concentric ring — Steps (outer) / Activity time (middle) / Calories (inner).
          Center(
            child: SizedBox(
              width: 220,
              height: 220,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 220,
                    height: 220,
                    child: CircularProgressIndicator(
                        value: stepProgress, strokeWidth: 14, backgroundColor: Colors.white12,
                        valueColor: const AlwaysStoppedAnimation(Color(0xFF9BE93B))),
                  ),
                  SizedBox(
                    width: 160,
                    height: 160,
                    child: CircularProgressIndicator(
                        value: activityProgress, strokeWidth: 14, backgroundColor: Colors.white12,
                        valueColor: const AlwaysStoppedAnimation(Color(0xFF3BB0E9))),
                  ),
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: CircularProgressIndicator(
                        value: calorieProgress, strokeWidth: 14, backgroundColor: Colors.white12,
                        valueColor: const AlwaysStoppedAnimation(Color(0xFFB93BE9))),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                  child: _StatTile(
                      color: const Color(0xFF9BE93B), label: 'Qadamlar', value: '$steps', goal: '/$_stepGoal')),
              const SizedBox(width: 12),
              Expanded(
                  child: _StatTile(
                      color: const Color(0xFF3BB0E9),
                      label: 'Faollik vaqti',
                      value: '$activityMinutes mín.',
                      goal: '/$_activityMinuteGoal')),
            ],
          ),
          const SizedBox(height: 12),
          _StatTile(color: const Color(0xFFB93BE9), label: 'Sarflangan kaloriya', value: '$calories kkal', wide: true),
          const SizedBox(height: 20),
          const Text('Bosib o\'tilgan masofa', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFF163B1F), borderRadius: BorderRadius.circular(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DistanceRow(icon: Icons.directions_walk, label: 'Piyoda', km: walkKm, exact: true),
                const Divider(color: Colors.white24, height: 20),
                _DistanceRow(icon: Icons.pedal_bike, label: 'Velosipedda', km: cyclingKm, exact: false),
                const Divider(color: Colors.white24, height: 20),
                _DistanceRow(icon: Icons.directions_car, label: 'Avtomobilda', km: vehicleKm, exact: false),
              ],
            ),
          ),
          const SizedBox(height: 8),
          if (_log != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                "Texnik: xom o'qish=${_log!.lastReading}, bugungi asos=${_log!.midnightBaseline}, farqi=${_log!.todaySteps}",
                style: const TextStyle(fontSize: 10, color: Colors.white30),
              ),
            ),
          const SizedBox(height: 8),
          const Text(
            "Velosiped/avtomobil masofasi — GPS ishlatilmagani uchun o'rtacha tezlik "
            "asosida taxminiy hisoblanadi. Piyoda masofasi qadam soniga asoslanib aniq hisoblanadi.",
            style: TextStyle(fontSize: 11, color: Colors.white38),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final Color color;
  final String label;
  final String value;
  final String? goal;
  final bool wide;
  const _StatTile({required this.color, required this.label, required this.value, this.goal, this.wide = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: wide ? double.infinity : null,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF1B1E24), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              if (goal != null)
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(goal!, style: const TextStyle(color: Colors.white38, fontSize: 12)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DistanceRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final double km;
  final bool exact;
  const _DistanceRow({required this.icon, required this.label, required this.km, required this.exact});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF9BE93B), size: 20),
        const SizedBox(width: 10),
        Expanded(child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 14))),
        Text('${exact ? '' : '~'}${km.toStringAsFixed(2)} km',
            style: const TextStyle(color: Color(0xFF9BE93B), fontSize: 15, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
