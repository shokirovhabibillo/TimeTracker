import 'package:pedometer/pedometer.dart';
import 'package:flutter/material.dart';

import '../../data/models/step_model.dart';
import '../../data/repositories/step_repository.dart';
import '../../widgets/coach_mark.dart';
import 'route_map_screen.dart';

class StepHomeScreen extends StatefulWidget {
  const StepHomeScreen({super.key});

  @override
  State<StepHomeScreen> createState() => _StepHomeScreenState();
}

class _StepHomeScreenState extends State<StepHomeScreen> {
  final _repository = StepRepository();
  StepLog? _log;
  String? _error;

  @override
  void initState() {
    super.initState();
    _listen();
  }

  void _listen() {
    Pedometer.stepCountStream.listen(_onStepCount).onError((e) {
      setState(() => _error = "Qadam sensori mavjud emas yoki ruxsat berilmagan.");
    });
  }

  Future<void> _onStepCount(StepCount event) async {
    final log = await _repository.getOrCreateTodayLog(event.steps);
    if (mounted) setState(() => _log = log);
  }

  @override
  Widget build(BuildContext context) {
    final steps = _log?.todaySteps ?? 0;
    final km = (_log?.todayDistanceMeters ?? 0) / 1000;
    // Rough estimate: ~0.04 kcal per step (average adult, moderate pace).
    final calories = (steps * 0.04).round();

    return Scaffold(
      backgroundColor: const Color(0xFF0F1115),
      appBar: AppBar(
        title: const Text('Qadam va masofa'),
        backgroundColor: const Color(0xFF0F1115),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.redAccent)),
              ),
            // Mi Band-style activity card.
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF9BE93B), Color(0xFF39D67A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('$steps',
                          style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold, color: Colors.black87)),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 12, left: 6),
                        child: Text('QADAM', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('${km.toStringAsFixed(2)} km', style: const TextStyle(color: Colors.black54, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _StatTile(icon: Icons.local_fire_department, label: 'Kaloriya', value: '$calories kcal')),
                const SizedBox(width: 12),
                Expanded(child: _StatTile(icon: Icons.straighten, label: 'Masofa', value: '${km.toStringAsFixed(2)} km')),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatTile(
                    icon: Icons.timer_outlined,
                    label: 'Taxminiy vaqt',
                    value: '${(steps / 100).round()} daq',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: _StatTile(icon: Icons.flag_outlined, label: 'Kunlik maqsad', value: '10 000 qadam')),
              ],
            ),
            const SizedBox(height: 24),
            CoachMark(
              id: 'step_route',
              message: "Bosilganda GPS orqali yurgan yo'lingiz shakli chiziladi",
              bubbleAbove: true,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RouteMapScreen())),
                icon: const Icon(Icons.route),
                label: const Text('Yurish shaklini chizib olish'),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Bu tugma bosilgan vaqtda GPS orqali yurgan yo'lingiz shakli chiziladi.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.5)),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _StatTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF1B1E24), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          const SizedBox(height: 10),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
        ],
      ),
    );
  }
}
