import 'dart:convert';
import 'dart:math';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/models/task_model.dart';

class FamilyLinkService {
  static final FamilyLinkService instance = FamilyLinkService._();
  FamilyLinkService._();

  SupabaseClient get _client => Supabase.instance.client;

  String _generateCode() {
    final rand = Random.secure();
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // no confusing 0/O/1/I
    return List.generate(8, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  /// Called on the child's device — creates a fresh pairing code tied
  /// to this device, valid until a parent links to it.
  Future<String> createPairingCode({required String childDeviceId, String? childName}) async {
    final code = _generateCode();
    await _client.from('family_links').insert({
      'pairing_code': code,
      'child_device_id': childDeviceId,
      'child_name': childName,
    });
    return code;
  }

  /// Polls whether [code] has been claimed by a parent yet — called
  /// periodically by the child's pairing screen.
  Future<bool> isCodeLinked(String code) async {
    final rows = await _client.from('family_links').select('linked_at').eq('pairing_code', code).limit(1);
    if (rows.isEmpty) return false;
    return rows.first['linked_at'] != null;
  }

  /// Called on the parent's device with the code shown on the child's
  /// screen. Returns the linked child's device id, or null if the code
  /// is invalid/already used.
  Future<String?> linkWithCode(String code, {required String parentDeviceId}) async {
    final rows = await _client.from('family_links').select().eq('pairing_code', code.toUpperCase()).limit(1);
    if (rows.isEmpty) return null;
    final row = rows.first;
    if (row['parent_device_id'] != null) return null; // already used

    await _client.from('family_links').update({
      'parent_device_id': parentDeviceId,
      'linked_at': DateTime.now().toIso8601String(),
    }).eq('pairing_code', code.toUpperCase());

    return row['child_device_id'] as String;
  }

  /// Called on the child's device to push today's plan up to the cloud
  /// so a linked parent can see it.
  Future<void> pushSnapshot({
    required String childDeviceId,
    required DateTime day,
    required List<TaskModel> tasks,
    required double dayProgress,
  }) async {
    final dateKey =
        '${day.year.toString().padLeft(4, '0')}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
    final tasksJson = jsonEncode(tasks
        .map((t) => {
              'title': t.title,
              'category': t.category,
              'start': t.startTime.toIso8601String(),
              'end': t.endTime.toIso8601String(),
              'completed': t.isCompleted,
              'status': t.completionStatus,
            })
        .toList());

    await _client.from('child_snapshots').upsert({
      'child_device_id': childDeviceId,
      'date': dateKey,
      'tasks_json': tasksJson,
      'day_progress': dayProgress,
      'updated_at': DateTime.now().toIso8601String(),
    }, onConflict: 'child_device_id,date');
  }

  /// Called on the parent's device to read a linked child's day.
  /// Returns null if there's no snapshot yet for that day.
  Future<({List<Map<String, dynamic>> tasks, double progress, DateTime updatedAt})?> fetchChildSnapshot(
      String childDeviceId, DateTime day) async {
    final dateKey =
        '${day.year.toString().padLeft(4, '0')}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
    final rows = await _client
        .from('child_snapshots')
        .select()
        .eq('child_device_id', childDeviceId)
        .eq('date', dateKey)
        .limit(1);
    if (rows.isEmpty) return null;
    final row = rows.first;
    final tasks = (jsonDecode(row['tasks_json'] as String) as List<dynamic>).cast<Map<String, dynamic>>();
    return (
      tasks: tasks,
      progress: (row['day_progress'] as num).toDouble(),
      updatedAt: DateTime.parse(row['updated_at'] as String),
    );
  }
}
