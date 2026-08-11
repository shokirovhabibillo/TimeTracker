import 'package:flutter/material.dart';

import '../../data/models/medicine_model.dart';
import '../../data/repositories/medicine_repository.dart';
import 'add_medicine_screen.dart';

class MedicationHomeScreen extends StatefulWidget {
  const MedicationHomeScreen({super.key});

  @override
  State<MedicationHomeScreen> createState() => _MedicationHomeScreenState();
}

class _MedicationHomeScreenState extends State<MedicationHomeScreen> {
  final _repository = MedicineRepository();
  List<Medicine> _todayMedicines = [];
  List<Medicine> _allMedicines = [];
  Set<String> _takenKeys = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final today = DateTime.now();
    _todayMedicines = await _repository.getActiveMedicinesForDay(today);
    _allMedicines = await _repository.getAllMedicines();
    _takenKeys = await _repository.getTakenDoseKeys(today);
    setState(() => _loading = false);
  }

  Future<void> _toggleDose(Medicine m, String time) async {
    final key = '${m.id}_$time';
    final newValue = !_takenKeys.contains(key);
    await _repository.setDoseTaken(m.id!, DateTime.now(), time, newValue);
    _load();
  }

  Future<void> _delete(Medicine m) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Dorini o'chirish"),
        content: Text('"${m.name}" o\'chirilsinmi?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text("Yo'q")),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Ha')),
        ],
      ),
    );
    if (confirmed == true) {
      await _repository.deleteMedicine(m.id!);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // Flattened list of (medicine, time) dose slots for today, sorted by time.
    final doseSlots = <({Medicine medicine, String time})>[];
    for (final m in _todayMedicines) {
      for (final t in m.times) {
        doseSlots.add((medicine: m, time: t));
      }
    }
    doseSlots.sort((a, b) => a.time.compareTo(b.time));

    return Scaffold(
      appBar: AppBar(title: const Text('Dori qabul qilish')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final saved = await Navigator.of(context).push<bool>(
            MaterialPageRoute(builder: (_) => const AddMedicineScreen()),
          );
          if (saved == true) _load();
        },
        icon: const Icon(Icons.add),
        label: const Text('Dori qo\'shish'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
              children: [
                Text("Bugungi dozalar", style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                if (doseSlots.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text("Bugun uchun dori belgilanmagan.", style: TextStyle(color: Theme.of(context).hintColor)),
                  )
                else
                  ...doseSlots.map((slot) {
                    final key = '${slot.medicine.id}_${slot.time}';
                    final taken = _takenKeys.contains(key);
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: taken ? Colors.green.withOpacity(0.15) : scheme.primary.withOpacity(0.12),
                          child: Icon(Icons.medication, color: taken ? Colors.green : scheme.primary, size: 20),
                        ),
                        title: Text(slot.medicine.name,
                            style: TextStyle(decoration: taken ? TextDecoration.lineThrough : null)),
                        subtitle: Text('${slot.medicine.dosage} · ${slot.time}'),
                        trailing: IconButton(
                          icon: Icon(taken ? Icons.check_circle : Icons.radio_button_unchecked,
                              color: taken ? Colors.green : null),
                          onPressed: () => _toggleDose(slot.medicine, slot.time),
                        ),
                      ),
                    );
                  }),
                const SizedBox(height: 24),
                Text('Barcha dorilar', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                if (_allMedicines.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text("Hali dori qo'shilmagan.", style: TextStyle(color: Theme.of(context).hintColor)),
                  )
                else
                  ..._allMedicines.map((m) => Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          title: Text(m.name),
                          subtitle: Text('${m.dosage} · ${m.times.join(", ")}'),
                          trailing: IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => _delete(m)),
                          onTap: () async {
                            final saved = await Navigator.of(context)
                                .push<bool>(MaterialPageRoute(builder: (_) => AddMedicineScreen(existing: m)));
                            if (saved == true) _load();
                          },
                        ),
                      )),
              ],
            ),
    );
  }
}
