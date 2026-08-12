import 'package:flutter/material.dart';

import '../../data/models/project_model.dart';
import '../../services/project_service.dart';

class AddProjectTaskScreen extends StatefulWidget {
  final Project project;
  final List<ProjectMember> members;
  final String myDeviceId;
  const AddProjectTaskScreen({super.key, required this.project, required this.members, required this.myDeviceId});

  @override
  State<AddProjectTaskScreen> createState() => _AddProjectTaskScreenState();
}

class _AddProjectTaskScreenState extends State<AddProjectTaskScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String _priority = TaskPriority.normal;
  String? _assignedTo;
  DateTime? _deadline;
  bool _saving = false;

  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (picked != null) setState(() => _deadline = picked);
  }

  Future<void> _save() async {
    if (_titleController.text.trim().isEmpty) return;
    setState(() => _saving = true);
    await ProjectService.instance.createTask(
      projectId: widget.project.id,
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      priority: _priority,
      assignedTo: _assignedTo,
      deadline: _deadline,
      createdBy: widget.myDeviceId,
    );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yangi vazifa')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Vazifa nomi')),
          const SizedBox(height: 12),
          TextField(controller: _descController, decoration: const InputDecoration(labelText: 'Tavsif (ixtiyoriy)'), maxLines: 3),
          const SizedBox(height: 16),
          Text('Muhimlik', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [TaskPriority.low, TaskPriority.normal, TaskPriority.high]
                .map((p) => ChoiceChip(
                      label: Text(TaskPriority.label(p)),
                      selected: _priority == p,
                      onSelected: (_) => setState(() => _priority = p),
                    ))
                .toList(),
          ),
          const SizedBox(height: 16),
          Text('Kimga biriktirilsin', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Hech kimga'),
                selected: _assignedTo == null,
                onSelected: (_) => setState(() => _assignedTo = null),
              ),
              ...widget.members.map((m) => ChoiceChip(
                    label: Text(m.memberName),
                    selected: _assignedTo == m.deviceId,
                    onSelected: (_) => setState(() => _assignedTo = m.deviceId),
                  )),
            ],
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _pickDeadline,
            icon: const Icon(Icons.event),
            label: Text(_deadline == null
                ? 'Muddat belgilash (ixtiyoriy)'
                : '${_deadline!.day}.${_deadline!.month}.${_deadline!.year}'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _saving ? null : _save,
            child: _saving ? const CircularProgressIndicator() : const Text('Qo\'shish'),
          ),
        ],
      ),
    );
  }
}
