class ProjectTaskStatus {
  static const todo = 'todo';
  static const inProgress = 'in_progress';
  static const done = 'done';
  static const all = [todo, inProgress, done];

  static String label(String s) {
    switch (s) {
      case inProgress:
        return 'Jarayonda';
      case done:
        return 'Bajarildi';
      default:
        return 'Bajarilmagan';
    }
  }
}

class TaskPriority {
  static const low = 'low';
  static const normal = 'normal';
  static const high = 'high';

  static String label(String p) {
    switch (p) {
      case low:
        return 'Past';
      case high:
        return 'Yuqori';
      default:
        return "O'rta";
    }
  }
}

class Project {
  final String id;
  final String name;
  final String? description;
  final String ownerDeviceId;
  final String inviteCode;
  final DateTime? deadline;
  final DateTime createdAt;

  Project({
    required this.id,
    required this.name,
    this.description,
    required this.ownerDeviceId,
    required this.inviteCode,
    this.deadline,
    required this.createdAt,
  });

  factory Project.fromMap(Map<String, dynamic> map) => Project(
        id: map['id'] as String,
        name: map['name'] as String,
        description: map['description'] as String?,
        ownerDeviceId: map['owner_device_id'] as String,
        inviteCode: map['invite_code'] as String,
        deadline: map['deadline'] != null ? DateTime.parse(map['deadline'] as String) : null,
        createdAt: DateTime.parse(map['created_at'] as String),
      );
}

class ProjectMember {
  final String deviceId;
  final String memberName;
  final String role;

  ProjectMember({required this.deviceId, required this.memberName, required this.role});

  factory ProjectMember.fromMap(Map<String, dynamic> map) => ProjectMember(
        deviceId: map['device_id'] as String,
        memberName: map['member_name'] as String,
        role: map['role'] as String,
      );
}

class ProjectTask {
  final String id;
  final String projectId;
  final String title;
  final String? description;
  final String status;
  final String priority;
  final String? assignedTo;
  final DateTime? deadline;
  final int orderIndex;

  ProjectTask({
    required this.id,
    required this.projectId,
    required this.title,
    this.description,
    this.status = ProjectTaskStatus.todo,
    this.priority = TaskPriority.normal,
    this.assignedTo,
    this.deadline,
    this.orderIndex = 0,
  });

  factory ProjectTask.fromMap(Map<String, dynamic> map) => ProjectTask(
        id: map['id'] as String,
        projectId: map['project_id'] as String,
        title: map['title'] as String,
        description: map['description'] as String?,
        status: map['status'] as String? ?? ProjectTaskStatus.todo,
        priority: map['priority'] as String? ?? TaskPriority.normal,
        assignedTo: map['assigned_to'] as String?,
        deadline: map['deadline'] != null ? DateTime.parse(map['deadline'] as String) : null,
        orderIndex: map['order_index'] as int? ?? 0,
      );
}
