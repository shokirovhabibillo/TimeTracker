import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/project_model.dart';
import '../../providers/settings_provider.dart';
import '../../services/project_service.dart';
import 'add_project_task_screen.dart';

class ProjectBoardScreen extends StatefulWidget {
  final Project project;
  const ProjectBoardScreen({super.key, required this.project});

  @override
  State<ProjectBoardScreen> createState() => _ProjectBoardScreenState();
}

class _ProjectBoardScreenState extends State<ProjectBoardScreen> {
  List<ProjectMember> _members = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadMembers());
  }

  Future<void> _loadMembers() async {
    final members = await ProjectService.instance.getMembers(widget.project.id);
    if (mounted) setState(() => _members = members);
  }

  String _memberName(String? deviceId) {
    if (deviceId == null) return '';
    final match = _members.where((m) => m.deviceId == deviceId);
    return match.isNotEmpty ? match.first.memberName : '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.project.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: "Taklif kodi",
            onPressed: () => showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text("Taklif kodi"),
                content: Text(widget.project.inviteCode,
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: 3)),
                actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK'))],
              ),
            ),
          ),
          IconButton(icon: const Icon(Icons.people_outline), tooltip: "A'zolar", onPressed: _showMembers),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final settings = context.read<SettingsProvider>().settings;
          await Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => AddProjectTaskScreen(project: widget.project, members: _members, myDeviceId: settings.deviceId),
          ));
        },
        icon: const Icon(Icons.add),
        label: const Text('Vazifa'),
      ),
      body: StreamBuilder<List<ProjectTask>>(
        stream: ProjectService.instance.watchTasks(widget.project.id),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final tasks = snapshot.data!;
          return Row(
            children: ProjectTaskStatus.all.map((status) {
              final columnTasks = tasks.where((t) => t.status == status).toList();
              return Expanded(
                child: DragTarget<ProjectTask>(
                  onAcceptWithDetails: (details) => ProjectService.instance.updateTaskStatus(details.data.id, status),
                  builder: (context, candidateData, rejectedData) {
                    final isHovering = candidateData.isNotEmpty;
                    return Container(
                      margin: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isHovering
                            ? Theme.of(context).colorScheme.primary.withOpacity(0.08)
                            : Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text('${ProjectTaskStatus.label(status)} (${columnTasks.length})',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                textAlign: TextAlign.center),
                          ),
                          Expanded(
                            child: ListView(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                              children: columnTasks
                                  .map((t) => LongPressDraggable<ProjectTask>(
                                        data: t,
                                        feedback: Material(
                                          elevation: 6,
                                          borderRadius: BorderRadius.circular(10),
                                          child: SizedBox(width: 140, child: _TaskCard(task: t, assignee: _memberName(t.assignedTo))),
                                        ),
                                        childWhenDragging: Opacity(opacity: 0.3, child: _TaskCard(task: t, assignee: _memberName(t.assignedTo))),
                                        child: _TaskCard(task: t, assignee: _memberName(t.assignedTo)),
                                      ))
                                  .toList(),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  void _showMembers() {
    showModalBottomSheet(
      context: context,
      builder: (context) => ListView(
        padding: const EdgeInsets.all(16),
        shrinkWrap: true,
        children: [
          Text("A'zolar", style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ..._members.map((m) => ListTile(
                leading: CircleAvatar(child: Text(m.memberName.isNotEmpty ? m.memberName[0].toUpperCase() : '?')),
                title: Text(m.memberName),
                subtitle: Text(m.role == 'owner' ? 'Egasi' : "A'zo"),
              )),
        ],
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final ProjectTask task;
  final String assignee;
  const _TaskCard({required this.task, required this.assignee});

  Color _priorityColor(BuildContext context) {
    switch (task.priority) {
      case TaskPriority.high:
        return Colors.red;
      case TaskPriority.low:
        return Colors.grey;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(width: 8, height: 8, decoration: BoxDecoration(color: _priorityColor(context), shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Expanded(child: Text(task.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
              ],
            ),
            if (assignee.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(children: [
                const Icon(Icons.person_outline, size: 12),
                const SizedBox(width: 4),
                Text(assignee, style: const TextStyle(fontSize: 11)),
              ]),
            ],
            if (task.deadline != null) ...[
              const SizedBox(height: 4),
              Text('${task.deadline!.day}.${task.deadline!.month}.${task.deadline!.year}',
                  style: TextStyle(fontSize: 10, color: Theme.of(context).hintColor)),
            ],
          ],
        ),
      ),
    );
  }
}
