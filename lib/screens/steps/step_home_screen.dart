import 'package:pedometer/pedometer.dart';
import 'package:flutter/material.dart';

import '../../data/models/step_model.dart';
import '../../data/repositories/step_repository.dart';
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
    final scheme = Theme.of(context).colorScheme;
    final steps = _log?.todaySteps ?? 0;
    final km = (_log?.todayDistanceMeters ?? 0) / 1000;

    return Scaffold(
      appBar: AppBar(title: const Text('Qadam va masofa')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(_error!, textAlign: TextAlign.center, style: TextStyle(color: scheme.error)),
                ),
              Icon(Icons.directions_walk, size: 56, color: scheme.primary),
              const SizedBox(height: 12),
              Text('$steps', style: TextStyle(fontSize: 56, fontWeight: FontWeight.bold, color: scheme.primary)),
              Text('bugungi qadam', style: TextStyle(color: Theme.of(context).hintColor)),
              const SizedBox(height: 16),
              Text('${km.toStringAsFixed(2)} km', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
              Text('taxminiy masofa (qadam uzunligi 0.75m)',
                  style: TextStyle(fontSize: 11, color: Theme.of(context).hintColor)),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const RouteMapScreen()),
                ),
                icon: const Icon(Icons.route),
                label: const Text('Yurish shaklini chizib olish'),
              ),
              const SizedBox(height: 8),
              Text(
                "Bu tugma bosilgan vaqtda GPS orqali yurgan yo'lingiz shakli chiziladi "
                "(ilova fonda ishlamasa, avtomatik davom etmaydi).",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: Theme.of(context).hintColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
