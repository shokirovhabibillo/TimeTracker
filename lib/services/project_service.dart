import 'dart:math';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/models/project_model.dart';

class ProjectService {
  static final ProjectService instance = ProjectService._();
  ProjectService._();

  SupabaseClient get _client => Supabase.instance.client;

  String _generateInviteCode() {
    final rand = Random.secure();
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    return List.generate(8, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  Future<Project> createProject({
    required String name,
    String? description,
    required String ownerDeviceId,
    required String ownerName,
    DateTime? deadline,
  }) async {
    final code = _generateInviteCode();
    final row = await _client
        .from('projects')
        .insert({
          'name': name,
          'description': description,
          'owner_device_id': ownerDeviceId,
          'invite_code': code,
          'deadline': deadline?.toIso8601String(),
        })
        .select()
        .single();
    final project = Project.fromMap(row);

    await _client.from('project_members').insert({
      'project_id': project.id,
      'device_id': ownerDeviceId,
      'member_name': ownerName,
      'role': 'owner',
    });

    return project;
  }

  /// Joins a project via its invite code. Returns the project, or null
  /// if the code doesn't match anything.
  Future<Project?> joinWithCode(String code, {required String deviceId, required String memberName}) async {
    final rows = await _client.from('projects').select().eq('invite_code', code.toUpperCase()).limit(1);
    if (rows.isEmpty) return null;
    final project = Project.fromMap(rows.first);

    await _client.from('project_members').upsert({
      'project_id': project.id,
      'device_id': deviceId,
      'member_name': memberName,
      'role': 'member',
    }, onConflict: 'project_id,device_id');

    return project;
  }

  /// All projects this device is a member of.
  Future<List<Project>> getMyProjects(String deviceId) async {
    final memberships = await _client.from('project_members').select('project_id').eq('device_id', deviceId);
    if (memberships.isEmpty) return [];
    final ids = memberships.map((m) => m['project_id'] as String).toList();
    final rows = await _client.from('projects').select().inFilter('id', ids).order('created_at');
    return rows.map((r) => Project.fromMap(r)).toList();
  }

  Future<List<ProjectMember>> getMembers(String projectId) async {
    final rows = await _client.from('project_members').select().eq('project_id', projectId);
    return rows.map((r) => ProjectMember.fromMap(r)).toList();
  }

  Future<List<ProjectTask>> getTasks(String projectId) async {
    final rows = await _client.from('project_tasks').select().eq('project_id', projectId).order('order_index');
    return rows.map((r) => ProjectTask.fromMap(r)).toList();
  }

  Future<void> createTask({
    required String projectId,
    required String title,
    String? description,
    String priority = TaskPriority.normal,
    String? assignedTo,
    DateTime? deadline,
    required String createdBy,
  }) async {
    await _client.from('project_tasks').insert({
      'project_id': projectId,
      'title': title,
      'description': description,
      'priority': priority,
      'assigned_to': assignedTo,
      'deadline': deadline?.toIso8601String(),
      'created_by': createdBy,
    });
  }

  Future<void> updateTaskStatus(String taskId, String status) async {
    await _client
        .from('project_tasks')
        .update({'status': status, 'updated_at': DateTime.now().toIso8601String()}).eq('id', taskId);
  }

  Future<void> deleteTask(String taskId) async {
    await _client.from('project_tasks').delete().eq('id', taskId);
  }

  Future<void> deleteProject(String projectId) async {
    await _client.from('projects').delete().eq('id', projectId);
  }

  /// Real-time stream of a project's tasks — updates live when any
  /// team member adds/moves/deletes a task.
  Stream<List<ProjectTask>> watchTasks(String projectId) {
    return _client
        .from('project_tasks')
        .stream(primaryKey: ['id'])
        .eq('project_id', projectId)
        .order('order_index')
        .map((rows) => rows.map((r) => ProjectTask.fromMap(r)).toList());
  }
}
