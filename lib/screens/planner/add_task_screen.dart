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
  TaskCategory.laborLeave: '#0EA5E9',
  TaskCategory.privilegedLeave: '#A855F7',
  TaskCategory.annualLeave: '#10B981',
  TaskCategory.idpDevelopment: '#F97316',
  TaskCategory.transport: '#0891B2',
  TaskCategory.custom: '#FF0055',
};

class AddTaskScreen extends StatefulWidget {
  final TaskModel? existing;
  final DateTime initialDay;
  final String? initialCategory;
  final String? initialTitle;
  const AddTaskScreen({super.key, this.existing, required this.initialDay, this.initialCategory, this.initialTitle});

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
  String? _durationUnit; // null = "Doim" (forever); else 'day'|'week'|'month'|'year'
  int _durationCount = 1;
  bool _isPassengerTransport = false;
  int _priority = 2;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _titleController = TextEditingController(text: e?.title ?? widget.initialTitle ?? '');
    _category = e?.category ?? widget.initialCategory ?? TaskCategory.work;
    _isPassengerTransport = e?.isPassengerTransport ?? false;
    _priority = e?.priority ?? 2;
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
    if (e?.recurrenceEndDate != null) {
      final totalDays = e!.recurrenceEndDate!.difference(_start).inDays;
      if (totalDays % 365 == 0 && totalDays > 0) {
        _durationUnit = 'year';
        _durationCount = totalDays ~/ 365;
      } else if (totalDays % 30 == 0 && totalDays > 0) {
        _durationUnit = 'month';
        _durationCount = totalDays ~/ 30;
      } else if (totalDays % 7 == 0 && totalDays > 0) {
        _durationUnit = 'week';
        _durationCount = totalDays ~/ 7;
      } else if (totalDays > 0) {
        _durationUnit = 'day';
        _durationCount = totalDays;
      }
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

  DateTime? _buildRecurrenceEndDate() {
    if (!_isRecurring || _durationUnit == null) return null;
    switch (_durationUnit) {
      case 'day':
        return _start.add(Duration(days: _durationCount));
      case 'week':
        return _start.add(Duration(days: _durationCount * 7));
      case 'month':
        return DateTime(_start.year, _start.month + _durationCount, _start.day,
            _start.hour, _start.minute);
      case 'year':
        return DateTime(_start.year + _durationCount, _start.month, _start.day,
            _start.hour, _start.minute);
      default:
        return null;
    }
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
      isPassengerTransport: _category == TaskCategory.transport && _isPassengerTransport,
      priority: _priority,
      colorCode: widget.existing?.colorCode ??
          _categoryDefaultColors[_category] ??
          '#00F0FF',
      startTime: _start,
      endTime: _end,
      isRecurring: _isRecurring,
      recurrenceRule: _buildRecurrenceRule(),
      recurrenceEndDate: _buildRecurrenceEndDate(),
      notificationOffsetMin: _notificationOffset,
      isCompleted: widget.existing?.isCompleted ?? false,
    );

    final provider = context.read<TaskProvider>();

    // Passenger-transport time is intentionally allowed to overlap
    // (that's the whole point — reading/study during a commute), so
    // skip the warning in that case, and skip it for the task being
    // edited itself.
    if (!task.isPassengerTransport) {
      final conflicts = provider.tasksForDay.where((t) =>
          t.id != task.id &&
          !t.isPassengerTransport &&
          t.startTime.isBefore(task.endTime) &&
          t.endTime.isAfter(task.startTime));
      if (conflicts.isNotEmpty && mounted) {
        final proceed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Vaqt to'qnashuvi"),
            content: Text(
              "Bu vaqt oralig'i quyidagilar bilan mos kelmoqda:\n\n"
              "${conflicts.map((t) => '• ${t.title}').join('\n')}\n\n"
              "Baribir saqlaysizmi?",
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Vaqtni o\'zgartiraman')),
              TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Baribir saqlash')),
            ],
          ),
        );
        if (proceed != true) return;
      }
    }

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
            const SizedBox(height: 12),
            Text('Muhimlik darajasi', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('🟢 Past'),
                  selected: _priority == 1,
                  onSelected: (_) => setState(() => _priority = 1),
                ),
                ChoiceChip(
                  label: const Text('🟡 Muhim'),
                  selected: _priority == 2,
                  onSelected: (_) => setState(() => _priority = 2),
                ),
                ChoiceChip(
                  label: const Text('🔴 Juda muhim'),
                  selected: _priority == 3,
                  onSelected: (_) => setState(() => _priority = 3),
                ),
              ],
            ),
            if (_category == TaskCategory.transport) ...[
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text("Yo'lovchiman (haydovchi emasman)"),
                subtitle: const Text(
                  "Yoqilsa, bu vaqt bo'sh vaqt hisobida ham ko'rsatiladi — yo'lda "
                  "o'qish, kitob o'qish yoki audio-dars tinglash uchun taklif qilinadi.",
                  style: TextStyle(fontSize: 11),
                ),
                value: _isPassengerTransport,
                onChanged: (v) => setState(() => _isPassengerTransport = v),
              ),
            ],
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
              const SizedBox(height: 12),
              const Text('Davomiyligi (rejaning umumiy muddati)',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                children: [
                  ChoiceChip(
                    label: const Text('Doim'),
                    selected: _durationUnit == null,
                    onSelected: (_) => setState(() => _durationUnit = null),
                  ),
                  ChoiceChip(
                    label: const Text('Kun'),
                    selected: _durationUnit == 'day',
                    onSelected: (_) => setState(() => _durationUnit = 'day'),
                  ),
                  ChoiceChip(
                    label: const Text('Hafta'),
                    selected: _durationUnit == 'week',
                    onSelected: (_) => setState(() => _durationUnit = 'week'),
                  ),
                  ChoiceChip(
                    label: const Text('Oy'),
                    selected: _durationUnit == 'month',
                    onSelected: (_) => setState(() => _durationUnit = 'month'),
                  ),
                  ChoiceChip(
                    label: const Text('Yil'),
                    selected: _durationUnit == 'year',
                    onSelected: (_) => setState(() => _durationUnit = 'year'),
                  ),
                ],
              ),
              if (_durationUnit != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () => setState(
                          () => _durationCount = (_durationCount - 1).clamp(1, 999)),
                    ),
                    Text('$_durationCount', style: const TextStyle(fontSize: 16)),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () => setState(
                          () => _durationCount = (_durationCount + 1).clamp(1, 999)),
                    ),
                    const SizedBox(width: 8),
                    Builder(builder: (context) {
                      final end = _buildRecurrenceEndDate();
                      if (end == null) return const SizedBox.shrink();
                      return Text('Tugaydi: ${DateFormat('d MMM yyyy').format(end)}',
                          style: TextStyle(color: Theme.of(context).hintColor, fontSize: 12));
                    }),
                  ],
                ),
              ],
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
