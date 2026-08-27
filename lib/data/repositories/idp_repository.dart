import '../database/database_helper.dart';
import '../models/idp_model.dart';

class IdpRepository {
  final _dbHelper = DatabaseHelper.instance;

  /// Creates a competency and seeds its three fixed 70-20-10 rows.
  Future<int> createCompetency(String name, String competencyType) async {
    final db = await _dbHelper.database;
    final id = await db.insert('idp_competencies', {
      'name': name,
      'competency_type': competencyType,
      'created_at': DateTime.now().toIso8601String(),
    });
    for (final bucket in IdpBucket.all) {
      await db.insert('idp_action_items', {
        'competency_id': id,
        'bucket': bucket,
        'purpose': '',
        'action_plan': '',
        'start_date': null,
        'end_date': null,
        'status': IdpStatus.notStarted,
        'achieved_result': '',
        'comment': '',
      });
    }
    return id;
  }

  /// Same as [createCompetency], but pre-fills each bucket's purpose
  /// (goal) and action plan (bulleted action list) from a catalog
  /// skill — used by the "Tayyor katalogdan tanlash" flow so the user
  /// gets a ready-made, non-generic 70-20-10 plan instead of blank
  /// fields to fill in by hand.
  Future<int> createCompetencyFromCatalog({
    required String name,
    required String goal,
    required List<String> actions70,
    required List<String> actions20,
    required List<String> actions10,
  }) async {
    final db = await _dbHelper.database;
    final id = await db.insert('idp_competencies', {
      'name': name,
      'competency_type': IdpCompetencyType.skill,
      'created_at': DateTime.now().toIso8601String(),
    });
    final byBucket = {
      IdpBucket.workplace: actions70,
      IdpBucket.mentorFeedback: actions20,
      IdpBucket.training: actions10,
    };
    for (final bucket in IdpBucket.all) {
      final actionText = (byBucket[bucket] ?? []).map((a) => '• $a').join('\n');
      await db.insert('idp_action_items', {
        'competency_id': id,
        'bucket': bucket,
        'purpose': goal,
        'action_plan': actionText,
        'start_date': null,
        'end_date': null,
        'status': IdpStatus.notStarted,
        'achieved_result': '',
        'comment': '',
      });
    }
    return id;
  }

  Future<void> updateCompetencyName(int id, String name) async {
    final db = await _dbHelper.database;
    await db.update('idp_competencies', {'name': name}, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteCompetency(int id) async {
    final db = await _dbHelper.database;
    await db.delete('idp_action_items', where: 'competency_id = ?', whereArgs: [id]);
    await db.delete('idp_competencies', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateActionItem(IdpActionItem item) async {
    final db = await _dbHelper.database;
    await db.update('idp_action_items', item.toMap(), where: 'id = ?', whereArgs: [item.id]);
  }

  Future<List<IdpCompetency>> getAllCompetencies({String? competencyType}) async {
    final db = await _dbHelper.database;
    final competencyMaps = competencyType != null
        ? await db.query('idp_competencies',
            where: 'competency_type = ?', whereArgs: [competencyType], orderBy: 'created_at DESC')
        : await db.query('idp_competencies', orderBy: 'created_at DESC');
    final result = <IdpCompetency>[];
    for (final cm in competencyMaps) {
      final itemMaps = await db.query(
        'idp_action_items',
        where: 'competency_id = ?',
        whereArgs: [cm['id']],
      );
      final items = itemMaps.map(IdpActionItem.fromMap).toList();
      items.sort((a, b) => IdpBucket.all.indexOf(a.bucket).compareTo(IdpBucket.all.indexOf(b.bucket)));
      result.add(IdpCompetency(
        id: cm['id'] as int,
        name: cm['name'] as String,
        competencyType: cm['competency_type'] as String? ?? IdpCompetencyType.skill,
        createdAt: DateTime.parse(cm['created_at'] as String),
        items: items,
      ));
    }
    return result;
  }
}
