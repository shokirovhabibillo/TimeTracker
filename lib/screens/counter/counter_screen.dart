import 'package:flutter/material.dart';

/// Simple, large tap-to-increment counter — useful for counting exercise
/// repetitions, dhikr, or any other repeated action.
class CounterScreen extends StatefulWidget {
  const CounterScreen({super.key});

  @override
  State<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> {
  int _count = 0;
  int _target = 0;

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

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final reachedTarget = _target > 0 && _count >= _target;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sanoq'),
        actions: [
          IconButton(icon: const Icon(Icons.flag_outlined), onPressed: _setTarget),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _reset),
        ],
      ),
      body: GestureDetector(
        onTap: _increment,
        behavior: HitTestBehavior.opaque,
        child: SafeArea(
          child: Column(
            children: [
              if (_target > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text('Maqsad: $_target',
                      style: TextStyle(color: Theme.of(context).hintColor)),
                ),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$_count',
                        style: TextStyle(
                          fontSize: 96,
                          fontWeight: FontWeight.bold,
                          color: reachedTarget ? Colors.green : scheme.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(reachedTarget ? "Maqsadga yetdingiz! 🎉" : 'Sanash uchun ekranga bosing',
                          style: TextStyle(color: Theme.of(context).hintColor)),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: ElevatedButton.icon(
                  onPressed: _decrement,
                  icon: const Icon(Icons.remove),
                  label: const Text('Bittaga kamaytirish'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
