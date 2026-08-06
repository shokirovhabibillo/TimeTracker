import 'package:flutter/material.dart';

import '../../data/models/flashcard_model.dart';
import '../../data/repositories/flashcard_repository.dart';
import '../../widgets/deck_screen.dart';

/// Language-learning home — CEFR-level word decks with spaced-repetition
/// review (SM-2 style, same engine used for the Qur'on deck).
class StudyHomeScreen extends StatefulWidget {
  const StudyHomeScreen({super.key});

  @override
  State<StudyHomeScreen> createState() => _StudyHomeScreenState();
}

class _StudyHomeScreenState extends State<StudyHomeScreen> {
  final _repository = FlashcardRepository();
  Map<String, int> _dueCounts = {};
  Map<String, int> _totalCounts = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final due = <String, int>{};
    final total = <String, int>{};
    for (final level in DeckType.languageLevels) {
      due[level] = await _repository.countDueInDeck(level);
      total[level] = await _repository.countTotalInDeck(level);
    }
    setState(() {
      _dueCounts = due;
      _totalCounts = total;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text("O'qish")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: scheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      "Darajani tanlang, o'z so'zlaringizni qo'shing va interval-takrorlash "
                      "(SM-2, Anki'dagidek) tizimi ularni eng yaxshi vaqtda qayta ko'rsatadi.",
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...DeckType.languageLevels.map((level) {
                    final due = _dueCounts[level] ?? 0;
                    final total = _totalCounts[level] ?? 0;
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(child: Text(level.split('_').last.toUpperCase())),
                        title: Text(DeckType.label(level)),
                        subtitle: Text('$total karta${due > 0 ? " · $due bugun takrorlanadi" : ""}'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () async {
                          await Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => DeckScreen(
                              deck: level,
                              frontLabel: "So'z (masalan: house)",
                              backLabel: 'Tarjima (masalan: uy)',
                            ),
                          ));
                          _load();
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
    );
  }
}
