import '../database/database_helper.dart';
import '../models/idp_model.dart';

class IdpRepository {
  final _dbHelper = DatabaseHelper.instance;

  /// Creates a competency and seeds its three fixed 70-20-10 rows.
  Future<int> createCompetency(String name) async {
    final db = await _dbHelper.database;
    final id = await db.insert('idp_competencies', {
      'name': name,
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

  Future<List<IdpCompetency>> getAllCompetencies() async {
    final db = await _dbHelper.database;
    final competencyMaps = await db.query('idp_competencies', orderBy: 'created_at DESC');
    final result = <IdpCompetency>[];
    for (final cm in competencyMaps) {
      final itemMaps = await db.query(
        'idp_action_items',
        where: 'competency_id = ?',
        whereArgs: [cm['id']],
      );
      final items = itemMaps.map(IdpActionItem.fromMap).toList();
      // Keep a stable 70-20-10 display order regardless of insert order.
      items.sort((a, b) => IdpBucket.all.indexOf(a.bucket).compareTo(IdpBucket.all.indexOf(b.bucket)));
      result.add(IdpCompetency(
        id: cm['id'] as int,
        name: cm['name'] as String,
        createdAt: DateTime.parse(cm['created_at'] as String),
        items: items,
      ));
    }
    return result;
  }
}
