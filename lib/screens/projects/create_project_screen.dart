import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/settings_provider.dart';
import '../../services/project_service.dart';

class CreateProjectScreen extends StatefulWidget {
  const CreateProjectScreen({super.key});

  @override
  State<CreateProjectScreen> createState() => _CreateProjectScreenState();
}

class _CreateProjectScreenState extends State<CreateProjectScreen> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _ownerNameController = TextEditingController();
  DateTime? _deadline;
  bool _saving = false;

  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (picked != null) setState(() => _deadline = picked);
  }

  Future<void> _create() async {
    if (_nameController.text.trim().isEmpty || _ownerNameController.text.trim().isEmpty) return;
    setState(() => _saving = true);
    final settings = context.read<SettingsProvider>().settings;
    final project = await ProjectService.instance.createProject(
      name: _nameController.text.trim(),
      description: _descController.text.trim(),
      ownerDeviceId: settings.deviceId,
      ownerName: _ownerNameController.text.trim(),
      deadline: _deadline,
    );
    if (!mounted) return;
    setState(() => _saving = false);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Loyiha yaratildi!"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Boshqa a'zolarni taklif qilish uchun shu kodni ulashing:"),
            const SizedBox(height: 12),
            Center(
              child: Text(project.inviteCode,
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 3)),
            ),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK'))],
      ),
    );
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yangi loyiha')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Loyiha nomi')),
          const SizedBox(height: 12),
          TextField(controller: _descController, decoration: const InputDecoration(labelText: 'Tavsif (ixtiyoriy)'), maxLines: 2),
          const SizedBox(height: 12),
          TextField(controller: _ownerNameController, decoration: const InputDecoration(labelText: 'Sizning ismingiz')),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _pickDeadline,
            icon: const Icon(Icons.event),
            label: Text(_deadline == null
                ? 'Muddat belgilash (ixtiyoriy)'
                : '${_deadline!.day}.${_deadline!.month}.${_deadline!.year}'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _saving ? null : _create,
            child: _saving ? const CircularProgressIndicator() : const Text('Yaratish'),
          ),
        ],
      ),
    );
  }
}
