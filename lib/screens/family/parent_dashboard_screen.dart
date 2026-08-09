import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/family_link_model.dart';
import '../../data/models/task_model.dart';
import '../../providers/settings_provider.dart';
import '../../services/family_link_service.dart';
import '../../services/notification_service.dart';
import '../../widgets/percentage_ring.dart';
import 'parent_pairing_screen.dart';

class ParentDashboardScreen extends StatefulWidget {
  const ParentDashboardScreen({super.key});

  @override
  State<ParentDashboardScreen> createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends State<ParentDashboardScreen> {
  List<Map<String, dynamic>>? _tasks;
  double _progress = 0;
  DateTime? _updatedAt;
  bool _loading = true;
  Timer? _pollTimer;
  Set<String> _lastCompletedTitles = {};

  @override
  void initState() {
    super.initState();
    _load(initial: true);
    _pollTimer = Timer.periodic(const Duration(seconds: 30), (_) => _load());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _load({bool initial = false}) async {
    final childId = context.read<SettingsProvider>().settings.linkedChildDeviceId;
    if (childId == null) return;
    if (initial) setState(() => _loading = true);

    final snapshot = await FamilyLinkService.instance.fetchChildSnapshot(childId, DateTime.now());
    if (!mounted) return;

    if (snapshot == null) {
      setState(() {
        _loading = false;
        _tasks = [];
      });
      return;
    }

    final completedNow = snapshot.tasks.where((t) => t['completed'] == true).map((t) => t['title'] as String).toSet();
    if (!initial) {
      final newlyCompleted = completedNow.difference(_lastCompletedTitles);
      for (final title in newlyCompleted) {
        NotificationService.instance.showChildActivityUpdate(title);
      }
    }
    _lastCompletedTitles = completedNow;

    setState(() {
      _tasks = snapshot.tasks;
      _progress = snapshot.progress;
      _updatedAt = snapshot.updatedAt;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Farzandim'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: () => _load()),
          PopupMenuButton<String>(
            onSelected: (v) async {
              if (v == 'relink') {
                await settings.setLinkedChild(null);
                if (mounted) {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ParentPairingScreen()));
                }
              } else if (v == 'exit') {
                await settings.setFamilyRole(DeviceRole.none);
                await settings.setLinkedChild(null);
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'relink', child: Text("Boshqa farzand bilan bog'lash")),
              PopupMenuItem(value: 'exit', child: Text("Rejimdan chiqish")),
            ],
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : (_tasks == null || _tasks!.isEmpty)
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      "Hali ma'lumot yo'q — farzandingiz telefonida ilova ochiq va "
                      "internetga ulangan bo'lishi kerak.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Theme.of(context).hintColor),
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Center(
                        child: Column(
                          children: [
                            PercentageRing(value: _progress, color: scheme.primary, size: 100),
                            const SizedBox(height: 8),
                            if (_updatedAt != null)
                              Text(
                                "Oxirgi yangilanish: ${_updatedAt!.hour.toString().padLeft(2, '0')}:${_updatedAt!.minute.toString().padLeft(2, '0')}",
                                style: TextStyle(fontSize: 11, color: Theme.of(context).hintColor),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      ..._tasks!.map((t) {
                        final completed = t['completed'] == true;
                        final start = DateTime.parse(t['start'] as String);
                        final end = DateTime.parse(t['end'] as String);
                        return Card(
                          child: ListTile(
                            leading: Icon(
                              completed ? Icons.check_circle : Icons.radio_button_unchecked,
                              color: completed ? Colors.green : Theme.of(context).hintColor,
                            ),
                            title: Text(t['title'] as String,
                                style: TextStyle(decoration: completed ? TextDecoration.lineThrough : null)),
                            subtitle: Text(
                                '${TaskCategory.label(t['category'] as String)} · ${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}–${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}'),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
    );
  }
}
