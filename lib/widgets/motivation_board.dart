import 'dart:math';
import 'package:flutter/material.dart';

import '../data/motivation_content.dart';

/// Compact card that cycles through [MotivationLibrary.items] — meant to
/// sit right next to the stopwatch/timer so a short break naturally
/// surfaces a dua, hadith, or piece of study wisdom instead of an empty
/// pause.
class MotivationBoard extends StatefulWidget {
  final String? taskCategory;
  const MotivationBoard({super.key, this.taskCategory});

  @override
  State<MotivationBoard> createState() => _MotivationBoardState();
}

class _MotivationBoardState extends State<MotivationBoard> {
  late List<MotivationItem> _pool;
  late int _index;

  @override
  void initState() {
    super.initState();
    _pool = MotivationLibrary.forTaskCategory(widget.taskCategory);
    _index = Random().nextInt(_pool.length);
  }

  @override
  void didUpdateWidget(covariant MotivationBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.taskCategory != widget.taskCategory) {
      setState(() {
        _pool = MotivationLibrary.forTaskCategory(widget.taskCategory);
        _index = Random().nextInt(_pool.length);
      });
    }
  }

  void _next() {
    setState(() => _index = (_index + 1) % _pool.length);
  }

  void _prev() {
    setState(() => _index = (_index - 1 + _pool.length) % _pool.length);
  }

  @override
  Widget build(BuildContext context) {
    final item = _pool[_index];
    final scheme = Theme.of(context).colorScheme;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: scheme.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(item.category,
                        style: TextStyle(fontSize: 10, color: scheme.primary, fontWeight: FontWeight.bold)),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.chevron_left, size: 18),
                    onPressed: _prev,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.chevron_right, size: 18),
                    onPressed: _next,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(item.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              if (item.transliteration != null) ...[
                const SizedBox(height: 6),
                Text(item.transliteration!,
                    style: TextStyle(
                        fontSize: 12, fontStyle: FontStyle.italic, color: scheme.primary)),
              ],
              const SizedBox(height: 6),
              Text(item.body, style: const TextStyle(fontSize: 12), maxLines: 5, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 6),
              Text(item.source,
                  style: TextStyle(fontSize: 10, color: scheme.onSurface.withOpacity(0.5))),
            ],
          ),
        ),
      ),
    );
  }
}
