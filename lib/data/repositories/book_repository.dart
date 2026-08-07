import '../database/database_helper.dart';
import '../models/book_model.dart';

class BookRepository {
  final _dbHelper = DatabaseHelper.instance;

  Future<BookEntry?> findByPath(String path) async {
    final db = await _dbHelper.database;
    final rows = await db.query('reading_books', where: 'file_path = ?', whereArgs: [path], limit: 1);
    if (rows.isEmpty) return null;
    return BookEntry.fromMap(rows.first);
  }

  Future<int> addOrUpdate(BookEntry book) async {
    final existing = await findByPath(book.filePath);
    final db = await _dbHelper.database;
    if (existing != null) {
      await db.update('reading_books', book.toMap()..['id'] = existing.id,
          where: 'id = ?', whereArgs: [existing.id]);
      return existing.id!;
    }
    return db.insert('reading_books', book.toMap()..remove('id'));
  }

  Future<void> updateProgress(int id, {required int lastPage, required int totalPages}) async {
    final db = await _dbHelper.database;
    await db.update(
      'reading_books',
      {'last_page': lastPage, 'total_pages': totalPages, 'last_opened_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteBook(int id) async {
    final db = await _dbHelper.database;
    await db.delete('reading_books', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<BookEntry>> getAllBooks() async {
    final db = await _dbHelper.database;
    final rows = await db.query('reading_books', orderBy: 'last_opened_at DESC');
    return rows.map(BookEntry.fromMap).toList();
  }

  Future<int> countFinishedBooks() async {
    final all = await getAllBooks();
    return all.where((b) => b.isFinished).length;
  }
}
