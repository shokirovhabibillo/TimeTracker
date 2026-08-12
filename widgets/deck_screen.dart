import 'package:flutter/material.dart';

import '../data/models/flashcard_model.dart';
import '../data/repositories/flashcard_repository.dart';
import 'flashcard_review_screen.dart';

class DeckScreen extends StatefulWidget {
  final String deck;
  final String frontLabel;
  final String backLabel;
  final bool showTransliteration;
  const DeckScreen({
    super.key,
    required this.deck,
    this.frontLabel = "So'z / ibora",
    this.backLabel = 'Tarjima',
    this.showTransliteration = false,
  });

  @override
  State<DeckScreen> createState() => _DeckScreenState();
}

class _DeckScreenState extends State<DeckScreen> {
  final _repository = FlashcardRepository();
  List<Flashcard> _cards = [];
  int _dueCount = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    _cards = await _repository.getAllInDeck(widget.deck);
    _dueCount = await _repository.countDueInDeck(widget.deck);
    setState(() => _loading = false);
  }

  Future<void> _addCard() async {
    final frontController = TextEditingController();
    final backController = TextEditingController();
    final transliterationController = TextEditingController();

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yangi karta'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: frontController, decoration: InputDecoration(labelText: widget.frontLabel)),
            if (widget.showTransliteration)
              TextField(
                  controller: transliterationController,
                  decoration: const InputDecoration(labelText: "O'qilishi (ixtiyoriy)")),
            TextField(controller: backController, decoration: InputDecoration(labelText: widget.backLabel)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text("Bekor qilish")),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text("Qo'shish")),
        ],
      ),
    );

    if (saved != true || frontController.text.trim().isEmpty) return;
    await _repository.createCard(Flashcard(
      deck: widget.deck,
      front: frontController.text.trim(),
      back: backController.text.trim(),
      transliteration:
          transliterationController.text.trim().isEmpty ? null : transliterationController.text.trim(),
      nextReviewDate: DateTime.now(),
      createdAt: DateTime.now(),
    ));
    _load();
  }

  Future<void> _deleteCard(Flashcard card) async {
    await _repository.deleteCard(card.id!);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(DeckType.label(widget.deck))),
      floatingActionButton: FloatingActionButton(onPressed: _addCard, child: const Icon(Icons.add)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton.icon(
                    onPressed: _dueCount == 0
                        ? null
                        : () async {
                            await Navigator.of(context)
                                .push(MaterialPageRoute(builder: (_) => FlashcardReviewScreen(deck: widget.deck)));
                            _load();
                          },
                    icon: const Icon(Icons.style),
                    label: Text(_dueCount > 0 ? "Bugungi takrorlash ($_dueCount)" : "Bugun takrorlash yo'q"),
                  ),
                ),
                Expanded(
                  child: _cards.isEmpty
                      ? Center(
                          child: Text("Hali karta qo'shilmagan — pastdagi + tugmasi orqali qo'shing",
                              style: TextStyle(color: Theme.of(context).hintColor)),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _cards.length,
                          itemBuilder: (context, i) {
                            final c = _cards[i];
                            final isDue = c.isDue;
                            return Card(
                              child: ListTile(
                                title: Text(c.front),
                                subtitle: Text(c.back),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (isDue)
                                      Icon(Icons.notifications_active, size: 16, color: scheme.primary)
                                    else
                                      Text('${c.intervalDays}d', style: const TextStyle(fontSize: 11)),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, size: 20),
                                      onPressed: () => _deleteCard(c),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
