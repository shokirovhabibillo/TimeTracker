import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../data/models/task_model.dart';
import '../../providers/task_provider.dart';

const Map<String, String> _categoryDefaultColors = {
  TaskCategory.work: '#00F0FF',
  TaskCategory.study: '#7B2CBF',
  TaskCategory.meal: '#39FF14',
  TaskCategory.sleep: '#5B7FDE',
  TaskCategory.habit: '#FFB000',
  TaskCategory.custom: '#FF0055',
};

class AddTaskScreen extends StatefulWidget {
  final TaskModel? existing;
  final DateTime initialDay;
  const AddTaskScreen({super.key, this.existing, required this.initialDay});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late String _category;
  late DateTime _start;
  late DateTime _end;
  bool _isRecurring = false;
  String _recurrenceType = 'DAILY';
  final Set<String> _weeklyDays = {};
  late int _notificationOffset;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _titleController = TextEditingController(text: e?.title ?? '');
    _category = e?.category ?? TaskCategory.work;
    _start = e?.startTime ??
        DateTime(widget.initialDay.year, widget.initialDay.month,
            widget.initialDay.day, 9);
    _end = e?.endTime ?? _start.add(const Duration(hours: 1));
    _isRecurring = e?.isRecurring ?? false;
    _notificationOffset = e?.notificationOffsetMin ?? 10;
    if (e?.recurrenceRule?.startsWith('WEEKLY') == true) {
      _recurrenceType = 'WEEKLY';
      final days = e!.recurrenceRule!.split(':').last.split(',');
      _weeklyDays.addAll(days);
    }
  }

  Future<void> _pickDateTime({required bool isStart}) async {
    final base = isStart ? _start : _end;
    final date = await showDatePicker(
      context: context,
      initialDate: base,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(base),
    );
    if (time == null) return;
    final combined = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    setState(() {
      if (isStart) {
        _start = combined;
        if (_end.isBefore(_start)) _end = _start.add(const Duration(hours: 1));
      } else {
        _end = combined;
      }
    });
  }

  String? _buildRecurrenceRule() {
    if (!_isRecurring) return null;
    if (_recurrenceType == 'DAILY') return 'DAILY';
    if (_weeklyDays.isEmpty) return null;
    return 'WEEKLY:${_weeklyDays.join(',')}';
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isRecurring && _recurrenceType == 'WEEKLY' && _weeklyDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hafta kunlarini tanlang')),
      );
      return;
    }

    final task = TaskModel(
      id: widget.existing?.id,
      title: _titleController.text.trim(),
      category: _category,
      colorCode: widget.existing?.colorCode ??
          _categoryDefaultColors[_category] ??
          '#00F0FF',
      startTime: _start,
      endTime: _end,
      isRecurring: _isRecurring,
      recurrenceRule: _buildRecurrenceRule(),
      notificationOffsetMin: _notificationOffset,
      isCompleted: widget.existing?.isCompleted ?? false,
    );

    final provider = context.read<TaskProvider>();
    if (widget.existing == null) {
      await provider.addTask(task);
    } else {
      await provider.updateTask(task);
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final timeFmt = DateFormat('d MMM, HH:mm');
    final weekDays = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existing == null ? 'Yangi vazifa' : 'Vazifani tahrirlash'),
        actions: [
          TextButton(onPressed: _save, child: const Text('Saqlash')),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Nomi'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Nom kiriting' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(labelText: 'Turkum'),
              items: TaskCategory.all
                  .map((c) => DropdownMenuItem(value: c, child: Text(TaskCategory.label(c))))
                  .toList(),
              onChanged: (v) => setState(() => _category = v!),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Boshlanish vaqti'),
              subtitle: Text(timeFmt.format(_start)),
              trailing: const Icon(Icons.edit_calendar),
              onTap: () => _pickDateTime(isStart: true),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Tugash vaqti'),
              subtitle: Text(timeFmt.format(_end)),
              trailing: const Icon(Icons.edit_calendar),
              onTap: () => _pickDateTime(isStart: false),
            ),
            const Divider(height: 32),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Takrorlanuvchi'),
              value: _isRecurring,
              onChanged: (v) => setState(() => _isRecurring = v),
            ),
            if (_isRecurring) ...[
              Row(
                children: [
                  ChoiceChip(
                    label: const Text('Har kuni'),
                    selected: _recurrenceType == 'DAILY',
                    onSelected: (_) => setState(() => _recurrenceType = 'DAILY'),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Har hafta'),
                    selected: _recurrenceType == 'WEEKLY',
                    onSelected: (_) => setState(() => _recurrenceType = 'WEEKLY'),
                  ),
                ],
              ),
              if (_recurrenceType == 'WEEKLY')
                Wrap(
                  spacing: 6,
                  children: weekDays.map((d) {
                    final selected = _weeklyDays.contains(d);
                    return FilterChip(
                      label: Text(d),
                      selected: selected,
                      onSelected: (v) => setState(
                          () => v ? _weeklyDays.add(d) : _weeklyDays.remove(d)),
                    );
                  }).toList(),
                ),
            ],
            const Divider(height: 32),
            Text('Eslatma: boshlanishidan $_notificationOffset daqiqa oldin'),
            Slider(
              value: _notificationOffset.toDouble(),
              min: 0,
              max: 60,
              divisions: 12,
              label: '$_notificationOffset daq',
              onChanged: (v) => setState(() => _notificationOffset = v.round()),
            ),
          ],
        ),
      ),
    );
  }
}
