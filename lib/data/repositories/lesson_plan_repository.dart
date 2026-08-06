import '../database/database_helper.dart';
import '../models/lesson_plan_model.dart';

class LessonPlanRepository {
  final _dbHelper = DatabaseHelper.instance;

  Future<int> createPlan(String name, List<LessonSegment> segments, {String domain = PlanDomain.teacher}) async {
    final db = await _dbHelper.database;
    final planId = await db.insert('lesson_plans', {
      'name': name,
      'created_at': DateTime.now().toIso8601String(),
      'domain': domain,
    });
    for (final s in segments) {
      await db.insert('lesson_segments', {
        'lesson_plan_id': planId,
        'segment_type': s.type,
        'duration_minutes': s.durationMinutes,
        'order_index': s.orderIndex,
      });
    }
    return planId;
  }

  Future<void> updatePlanSegments(int planId, String name, List<LessonSegment> segments) async {
    final db = await _dbHelper.database;
    await db.update('lesson_plans', {'name': name}, where: 'id = ?', whereArgs: [planId]);
    await db.delete('lesson_segments', where: 'lesson_plan_id = ?', whereArgs: [planId]);
    for (final s in segments) {
      await db.insert('lesson_segments', {
        'lesson_plan_id': planId,
        'segment_type': s.type,
        'duration_minutes': s.durationMinutes,
        'order_index': s.orderIndex,
      });
    }
  }

  Future<void> deletePlan(int planId) async {
    final db = await _dbHelper.database;
    await db.delete('lesson_segments', where: 'lesson_plan_id = ?', whereArgs: [planId]);
    await db.delete('lesson_plans', where: 'id = ?', whereArgs: [planId]);
  }

  Future<List<LessonPlanModel>> getAllPlans({String? domain}) async {
    final db = await _dbHelper.database;
    final planMaps = domain != null
        ? await db.query('lesson_plans', where: 'domain = ?', whereArgs: [domain], orderBy: 'created_at DESC')
        : await db.query('lesson_plans', orderBy: 'created_at DESC');
    final plans = <LessonPlanModel>[];
    for (final pm in planMaps) {
      final segMaps = await db.query(
        'lesson_segments',
        where: 'lesson_plan_id = ?',
        whereArgs: [pm['id']],
        orderBy: 'order_index ASC',
      );
      plans.add(LessonPlanModel(
        id: pm['id'] as int,
        name: pm['name'] as String,
        createdAt: DateTime.parse(pm['created_at'] as String),
        segments: segMaps.map(LessonSegment.fromMap).toList(),
        domain: pm['domain'] as String? ?? PlanDomain.teacher,
      ));
    }
    return plans;
  }
}
