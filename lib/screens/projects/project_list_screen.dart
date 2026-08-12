import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/supabase_config.dart';
import '../../data/models/project_model.dart';
import '../../providers/settings_provider.dart';
import '../../services/project_service.dart';
import 'create_project_screen.dart';
import 'join_project_screen.dart';
import 'project_board_screen.dart';

class ProjectListScreen extends StatefulWidget {
  const ProjectListScreen({super.key});

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  List<Project>? _projects;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final deviceId = context.read<SettingsProvider>().settings.deviceId;
    final projects = await ProjectService.instance.getMyProjects(deviceId);
    if (mounted) setState(() => _projects = projects);
  }

  @override
  Widget build(BuildContext context) {
    if (!SupabaseConfig.isConfigured) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loyihalar')),
        body: const Padding(
          padding: EdgeInsets.all(24),
          child: Center(
            child: Text(
              "Bu funksiya hali sozlanmagan — dasturchi tomonidan Supabase ulanishi kiritilishi kerak.",
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Loyihalar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.group_add_outlined),
            tooltip: 'Kod bilan qo\'shilish',
            onPressed: () async {
              final joined = await Navigator.of(context).push<bool>(
                MaterialPageRoute(builder: (_) => const JoinProjectScreen()),
              );
              if (joined == true) _load();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final created = await Navigator.of(context).push<bool>(
            MaterialPageRoute(builder: (_) => const CreateProjectScreen()),
          );
          if (created == true) _load();
        },
        icon: const Icon(Icons.add),
        label: const Text('Yangi loyiha'),
      ),
      body: _projects == null
          ? const Center(child: CircularProgressIndicator())
          : _projects!.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.folder_open, size: 48),
                        const SizedBox(height: 12),
                        const Text(
                          "Hali loyihangiz yo'q. Yangi loyiha yarating yoki "
                          "boshqa a'zoning taklif kodini kiriting.",
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                    itemCount: _projects!.length,
                    itemBuilder: (context, i) {
                      final p = _projects![i];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          leading: const CircleAvatar(child: Icon(Icons.folder)),
                          title: Text(p.name),
                          subtitle: Text(p.description?.isNotEmpty == true
                              ? p.description!
                              : 'Kod: ${p.inviteCode}'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => Navigator.of(context)
                              .push(MaterialPageRoute(builder: (_) => ProjectBoardScreen(project: p))),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
