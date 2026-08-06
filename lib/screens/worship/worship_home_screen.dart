import 'package:flutter/material.dart';

import '../../data/models/flashcard_model.dart';
import '../../data/motivation_content.dart';
import '../../data/repositories/flashcard_repository.dart';
import '../../widgets/deck_screen.dart';

/// Browsable home for the spiritual content already curated for the
/// Motivation Board — organized by category so it can be read at leisure
/// rather than only encountered one-at-a-time during a break. Also hosts
/// the Qur'on memorization deck (same SRS engine as the language decks).
class WorshipHomeScreen extends StatefulWidget {
  const WorshipHomeScreen({super.key});

  @override
  State<WorshipHomeScreen> createState() => _WorshipHomeScreenState();
}

class _WorshipHomeScreenState extends State<WorshipHomeScreen> {
  final _repository = FlashcardRepository();
  int _dueCount = 0;
  int _totalCount = 0;

  static const _categories = ['Duo', 'Hadis', 'Olim hikoyasi', 'Taxorat', "Ma'naviyat"];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final due = await _repository.countDueInDeck(DeckType.quran);
    final total = await _repository.countTotalInDeck(DeckType.quran);
    setState(() {
      _dueCount = due;
      _totalCount = total;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Ibodat')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: scheme.primary.withOpacity(0.08),
            child: ListTile(
              leading: CircleAvatar(child: Icon(Icons.menu_book, color: scheme.primary)),
              title: const Text("Qur'on yodlash"),
              subtitle: Text('$_totalCount oyat/juz${_dueCount > 0 ? " · $_dueCount bugun takrorlanadi" : ""}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                await Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const DeckScreen(
                    deck: DeckType.quran,
                    frontLabel: 'Oyat/Sura nomi',
                    backLabel: "Ma'nosi / eslatma",
                    showTransliteration: true,
                  ),
                ));
                _load();
              },
            ),
          ),
          const SizedBox(height: 20),
          ..._categories.map((category) {
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
        ],
      ),
    );
  }
}
