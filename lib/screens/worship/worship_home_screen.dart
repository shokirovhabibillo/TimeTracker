import 'package:flutter/material.dart';

import '../../data/motivation_content.dart';

/// Browsable home for the spiritual content already curated for the
/// Motivation Board — organized by category so it can be read at leisure
/// rather than only encountered one-at-a-time during a break.
class WorshipHomeScreen extends StatelessWidget {
  const WorshipHomeScreen({super.key});

  static const _categories = ['Duo', 'Hadis', 'Olim hikoyasi', 'Taxorat', "Ma'naviyat"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ibodat')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: _categories.map((category) {
          final items = MotivationLibrary.items.where((i) => i.category == category).toList();
          if (items.isEmpty) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(category, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                ...items.map((item) => Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                            if (item.transliteration != null) ...[
                              const SizedBox(height: 6),
                              Text(item.transliteration!,
                                  style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      color: Theme.of(context).colorScheme.primary)),
                            ],
                            const SizedBox(height: 6),
                            Text(item.body),
                            const SizedBox(height: 6),
                            Text(item.source,
                                style: TextStyle(
                                    fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
                          ],
                        ),
                      ),
                    )),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
