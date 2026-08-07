import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../services/audio_service.dart';

/// Simple, large tap-to-increment counter — useful for counting exercise
/// repetitions, dhikr, or any other repeated action. Keeps the screen
/// awake while open, and lets the user label what they're counting with
/// text and/or a picture.
class CounterScreen extends StatefulWidget {
  const CounterScreen({super.key});

  @override
  State<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> {
  int _count = 0;
  int _target = 0;
  String? _label;
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    ScreenWakeService.enable();
  }

  @override
  void dispose() {
    ScreenWakeService.disable();
    super.dispose();
  }

  void _increment() => setState(() => _count++);
  void _decrement() => setState(() => _count = (_count - 1).clamp(0, 999999));
  void _reset() => setState(() => _count = 0);

  Future<void> _setTarget() async {
    final controller = TextEditingController(text: _target > 0 ? '$_target' : '');
    final value = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Maqsad son (ixtiyoriy)'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: 'Masalan: 100'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(''), child: const Text('Tozalash')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    if (value == null) return;
    setState(() => _target = int.tryParse(value) ?? 0);
  }

  Future<void> _setLabel() async {
    final controller = TextEditingController(text: _label ?? '');
    final value = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nimani sanayapsiz?'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Masalan: Turnikda tortilish, Tasbeh..."),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(''), child: const Text('Tozalash')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Saqlash'),
          ),
        ],
      ),
    );
    if (value == null) return;
    setState(() => _label = value.isEmpty ? null : value);
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    final path = result?.files.single.path;
    if (path == null) return;
    setState(() => _imagePath = path);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final reachedTarget = _target > 0 && _count >= _target;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sanoq'),
        actions: [
          IconButton(icon: const Icon(Icons.edit_note), tooltip: 'Nomi', onPressed: _setLabel),
          IconButton(icon: const Icon(Icons.image_outlined), tooltip: 'Rasm', onPressed: _pickImage),
          IconButton(icon: const Icon(Icons.flag_outlined), tooltip: 'Maqsad', onPressed: _setTarget),
          IconButton(icon: const Icon(Icons.refresh), tooltip: 'Tozalash', onPressed: _reset),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_imagePath != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(File(_imagePath!), width: 140, height: 140, fit: BoxFit.cover),
                    ),
                  if (_label != null) ...[
                    const SizedBox(height: 12),
                    Text(_label!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  ],
                  if (_target > 0) ...[
                    const SizedBox(height: 8),
                    Text('Maqsad: $_target', style: TextStyle(color: Theme.of(context).hintColor)),
                  ],
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: _increment,
                    child: Text(
                      '$_count',
                      style: TextStyle(
                        fontSize: 110,
                        fontWeight: FontWeight.bold,
                        color: reachedTarget ? Colors.green : scheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(reachedTarget ? "Maqsadga yetdingiz! \ud83c\udf89" : 'Sanash uchun raqamga yoki + tugmasiga bosing',
                      style: TextStyle(color: Theme.of(context).hintColor)),
                ],
              ),
            ),
            Positioned(
              left: 24,
              bottom: 24,
              child: FloatingActionButton(
                heroTag: 'minus',
                backgroundColor: scheme.secondary,
                onPressed: _decrement,
                child: const Icon(Icons.remove, size: 32),
              ),
            ),
            Positioned(
              right: 24,
              bottom: 24,
              child: FloatingActionButton(
                heroTag: 'plus',
                backgroundColor: scheme.primary,
                onPressed: _increment,
                child: const Icon(Icons.add, size: 32),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
