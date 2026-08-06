import '../database/database_helper.dart';
import '../models/flashcard_model.dart';

class FlashcardRepository {
  final _dbHelper = DatabaseHelper.instance;

  Future<int> createCard(Flashcard card) async {
    final db = await _dbHelper.database;
    return db.insert('flashcards', card.toMap()..remove('id'));
  }

  Future<void> updateCard(Flashcard card) async {
    final db = await _dbHelper.database;
    await db.update('flashcards', card.toMap(), where: 'id = ?', whereArgs: [card.id]);
  }

  Future<void> deleteCard(int id) async {
    final db = await _dbHelper.database;
    await db.delete('flashcards', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Flashcard>> getAllInDeck(String deck) async {
    final db = await _dbHelper.database;
    final maps = await db.query('flashcards', where: 'deck = ?', whereArgs: [deck], orderBy: 'created_at ASC');
    return maps.map(Flashcard.fromMap).toList();
  }

  Future<List<Flashcard>> getDueInDeck(String deck) async {
    final db = await _dbHelper.database;
    final now = DateTime.now().toIso8601String();
    final maps = await db.query(
      'flashcards',
      where: 'deck = ? AND next_review_date <= ?',
      whereArgs: [deck, now],
      orderBy: 'next_review_date ASC',
    );
    return maps.map(Flashcard.fromMap).toList();
  }

  Future<int> countDueInDeck(String deck) async {
    final db = await _dbHelper.database;
    final now = DateTime.now().toIso8601String();
    final result = await db.rawQuery(
      'SELECT COUNT(*) as c FROM flashcards WHERE deck = ? AND next_review_date <= ?',
      [deck, now],
    );
    return (result.first['c'] as int?) ?? 0;
  }

  Future<int> countTotalInDeck(String deck) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) as c FROM flashcards WHERE deck = ?', [deck]);
    return (result.first['c'] as int?) ?? 0;
  }
}
