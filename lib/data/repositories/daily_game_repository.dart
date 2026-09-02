import '../database/database_helper.dart';

class DailyGameEntry {
  final String gameId;
  final String date; // yyyy-MM-dd
  final DateTime sessionStartAt;
  final DateTime? completedAt;
  final int score;

  DailyGameEntry({
    required this.gameId,
    required this.date,
    required this.sessionStartAt,
    this.completedAt,
    this.score = 0,
  });

  /// Seconds left in the 30-second session, computed from the real
  /// session start timestamp — backgrounding/restarting the app can't
  /// grant extra time since this is wall-clock based, not a paused timer.
  int remainingSeconds(int sessionLengthSeconds) {
    final elapsed = DateTime.now().difference(sessionStartAt).inSeconds;
    return (sessionLengthSeconds - elapsed).clamp(0, sessionLengthSeconds);
  }

  bool get isCompleted => completedAt != null;

  factory DailyGameEntry.fromMap(Map<String, dynamic> map) => DailyGameEntry(
        gameId: map['game_id'] as String,
        date: map['date'] as String,
        sessionStartAt: DateTime.parse(map['session_start_at'] as String),
        completedAt: map['completed_at'] != null ? DateTime.parse(map['completed_at'] as String) : null,
        score: map['score'] as int? ?? 0,
      );
}

class DailyGameRepository {
  final _dbHelper = DatabaseHelper.instance;

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// Returns today's entry for [gameId] if a session was already
  /// started today (playing or completed), or null if today is fresh.
  Future<DailyGameEntry?> getTodayEntry(String gameId) async {
    final db = await _dbHelper.database;
    final rows = await db.query('daily_game_log',
        where: 'game_id = ? AND date = ?', whereArgs: [gameId, _todayKey()], limit: 1);
    if (rows.isEmpty) return null;
    return DailyGameEntry.fromMap(rows.first);
  }

  /// Starts (or resumes) today's session — idempotent: if a session
  /// already exists today it's returned unchanged, so re-entering the
  /// screen never resets the 30-second window.
  Future<DailyGameEntry> startOrResumeSession(String gameId) async {
    final existing = await getTodayEntry(gameId);
    if (existing != null) return existing;

    final db = await _dbHelper.database;
    final now = DateTime.now();
    await db.insert('daily_game_log', {
      'game_id': gameId,
      'date': _todayKey(),
      'session_start_at': now.toIso8601String(),
      'completed_at': null,
      'score': 0,
    });
    return DailyGameEntry(gameId: gameId, date: _todayKey(), sessionStartAt: now);
  }

  /// Whether any daily game was played on [day] — used by the Monthly
  /// Report to show "what else happened" on a given day, not just plan
  /// completion.
  Future<bool> anyGamePlayedOnDay(DateTime day) async {
    final db = await _dbHelper.database;
    final key =
        '${day.year.toString().padLeft(4, '0')}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
    final rows = await db.query('daily_game_log', where: 'date = ?', whereArgs: [key], limit: 1);
    return rows.isNotEmpty;
  }

  Future<void> completeSession(String gameId, int score) async {
    final db = await _dbHelper.database;
    await db.update(
      'daily_game_log',
      {'completed_at': DateTime.now().toIso8601String(), 'score': score},
      where: 'game_id = ? AND date = ?',
      whereArgs: [gameId, _todayKey()],
    );
  }
}
