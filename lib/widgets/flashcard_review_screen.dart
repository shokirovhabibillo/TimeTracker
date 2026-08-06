import 'package:flutter/material.dart';

import '../data/models/flashcard_model.dart';
import '../data/repositories/flashcard_repository.dart';

class FlashcardReviewScreen extends StatefulWidget {
  final String deck;
  const FlashcardReviewScreen({super.key, required this.deck});

  @override
  State<FlashcardReviewScreen> createState() => _FlashcardReviewScreenState();
}

class _FlashcardReviewScreenState extends State<FlashcardReviewScreen> {
  final _repository = FlashcardRepository();
  List<Flashcard> _queue = [];
  bool _loading = true;
  bool _showBack = false;
  int _reviewedCount = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    _queue = await _repository.getDueInDeck(widget.deck);
    setState(() => _loading = false);
  }

  Future<void> _rate(RecallQuality quality) async {
    final card = _queue.first;
    final updated = card.reviewed(quality);
    await _repository.updateCard(updated);
    setState(() {
      _queue.removeAt(0);
      _showBack = false;
      _reviewedCount++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text('${DeckType.label(widget.deck)} — takrorlash')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _queue.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.celebration, size: 48, color: scheme.primary),
                        const SizedBox(height: 12),
                        Text(_reviewedCount > 0
                            ? "Bugungi takrorlash tugadi! ($_reviewedCount karta)"
                            : "Bugun takrorlash uchun karta yo'q."),
                      ],
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text('Qolgan: ${_queue.length}', style: TextStyle(color: Theme.of(context).hintColor)),
                      const SizedBox(height: 16),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _showBack = !_showBack),
                          child: Card(
                            elevation: 3,
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      _showBack ? _queue.first.back : _queue.first.front,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                                    ),
                                    if (_showBack && _queue.first.transliteration != null) ...[
                                      const SizedBox(height: 12),
                                      Text(_queue.first.transliteration!,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontStyle: FontStyle.italic, color: scheme.primary)),
                                    ],
                                    const SizedBox(height: 16),
                                    if (!_showBack)
                                      Text("Ko'rish uchun bosing", style: TextStyle(color: Theme.of(context).hintColor)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_showBack)
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                onPressed: () => _rate(RecallQuality.again),
                                child: const Text('Yana'),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                                onPressed: () => _rate(RecallQuality.hard),
                                child: const Text('Qiyin'),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                onPressed: () => _rate(RecallQuality.good),
                                child: const Text('Yaxshi'),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                                onPressed: () => _rate(RecallQuality.easy),
                                child: const Text('Oson'),
                              ),
                            ),
                          ],
                        )
                      else
                        ElevatedButton(
                          onPressed: () => setState(() => _showBack = true),
                          child: const Text('Javobni ko\'rsat'),
                        ),
                    ],
                  ),
                ),
    );
  }
}
