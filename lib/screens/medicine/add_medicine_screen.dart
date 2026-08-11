import 'package:flutter/material.dart';

import '../../data/models/medicine_model.dart';
import '../../data/repositories/medicine_repository.dart';
import '../../services/notification_service.dart';

class AddMedicineScreen extends StatefulWidget {
  final Medicine? existing;
  const AddMedicineScreen({super.key, this.existing});

  @override
  State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  final _repository = MedicineRepository();
  late final TextEditingController _nameController;
  late final TextEditingController _dosageController;
  late final TextEditingController _notesController;
  late List<TimeOfDay> _times;
  late DateTime _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameController = TextEditingController(text: e?.name ?? '');
    _dosageController = TextEditingController(text: e?.dosage ?? '1 tabletka');
    _notesController = TextEditingController(text: e?.notes ?? '');
    _times = e?.times.map((t) {
          final parts = t.split(':');
          return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
        }).toList() ??
        [const TimeOfDay(hour: 9, minute: 0)];
    _startDate = e?.startDate ?? DateTime.now();
    _endDate = e?.endDate;
  }

  Future<void> _addTime() async {
    final picked = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 20, minute: 0));
    if (picked != null) setState(() => _times.add(picked));
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _startDate = picked);
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate,
      firstDate: _startDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _endDate = picked);
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty || _times.isEmpty) return;
    final timeStrings = _times.map((t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}').toList()
      ..sort();

    final medicine = Medicine(
      id: widget.existing?.id,
      name: _nameController.text.trim(),
      dosage: _dosageController.text.trim(),
      times: timeStrings,
      startDate: _startDate,
      endDate: _endDate,
      notes: _notesController.text.trim(),
    );

    int id;
    if (widget.existing?.id != null) {
      id = widget.existing!.id!;
      await _repository.updateMedicine(medicine);
    } else {
      id = await _repository.createMedicine(medicine);
    }

    // Schedule a daily reminder notification for each dose time.
    for (var i = 0; i < timeStrings.length; i++) {
      final t = _times[i];
      await NotificationService.instance.scheduleMedicineReminder(
        medicineNotificationId: id * 100 + i,
        title: "Dori vaqti: ${medicine.name}",
        body: medicine.dosage,
        hour: t.hour,
        minute: t.minute,
      );
    }

    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existing == null ? "Dori qo'shish" : 'Dorini tahrirlash'),
        actions: [TextButton(onPressed: _save, child: const Text('Saqlash'))],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Dori nomi')),
          const SizedBox(height: 12),
          TextField(controller: _dosageController, decoration: const InputDecoration(labelText: "Doza (masalan: 1 tabletka)")),
          const SizedBox(height: 16),
          Text('Qabul qilish vaqtlari', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var i = 0; i < _times.length; i++)
                InputChip(
                  label: Text(_times[i].format(context)),
                  onDeleted: _times.length > 1 ? () => setState(() => _times.removeAt(i)) : null,
                ),
              ActionChip(avatar: const Icon(Icons.add, size: 16), label: const Text('Vaqt qo\'shish'), onPressed: _addTime),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _pickStartDate,
                  child: Text('Boshlanishi: ${_startDate.day}.${_startDate.month}.${_startDate.year}'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: _pickEndDate,
                  child: Text(_endDate != null
                      ? 'Tugashi: ${_endDate!.day}.${_endDate!.month}.${_endDate!.year}'
                      : 'Tugash (ixtiyoriy)'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notesController,
            decoration: const InputDecoration(labelText: 'Izoh (ixtiyoriy)'),
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}
