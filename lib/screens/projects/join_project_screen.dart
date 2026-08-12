import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/settings_provider.dart';
import '../../services/project_service.dart';

class JoinProjectScreen extends StatefulWidget {
  const JoinProjectScreen({super.key});

  @override
  State<JoinProjectScreen> createState() => _JoinProjectScreenState();
}

class _JoinProjectScreenState extends State<JoinProjectScreen> {
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _join() async {
    final code = _codeController.text.trim();
    if (code.isEmpty || _nameController.text.trim().isEmpty) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final settings = context.read<SettingsProvider>().settings;
    final project = await ProjectService.instance.joinWithCode(
      code,
      deviceId: settings.deviceId,
      memberName: _nameController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (project == null) {
      setState(() => _error = "Kod topilmadi. Qayta tekshiring.");
      return;
    }
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Loyihaga qo'shilish")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text("Loyiha egasidan olgan taklif kodini kiriting:"),
            const SizedBox(height: 12),
            TextField(
              controller: _codeController,
              textAlign: TextAlign.center,
              textCapitalization: TextCapitalization.characters,
              style: const TextStyle(fontSize: 22, letterSpacing: 3, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'ABCD1234'),
            ),
            const SizedBox(height: 12),
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Sizning ismingiz')),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loading ? null : _join,
              child: _loading ? const CircularProgressIndicator() : const Text("Qo'shilish"),
            ),
          ],
        ),
      ),
    );
  }
}
