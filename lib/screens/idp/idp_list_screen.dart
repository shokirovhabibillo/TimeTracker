import 'package:flutter/material.dart';

import '../../data/models/idp_model.dart';
import '../../data/repositories/idp_repository.dart';
import 'idp_edit_screen.dart';

class IdpListScreen extends StatefulWidget {
  const IdpListScreen({super.key});

  @override
  State<IdpListScreen> createState() => _IdpListScreenState();
}

class _IdpListScreenState extends State<IdpListScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(length: 2, vsync: this);
  final _repository = IdpRepository();
  List<IdpCompetency> _skills = [];
  List<IdpCompetency> _knowledge = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String get _currentType =>
      _tabController.index == 0 ? IdpCompetencyType.skill : IdpCompetencyType.knowledge;

  Future<void> _load() async {
    setState(() => _loading = true);
    _skills = await _repository.getAllCompetencies(competencyType: IdpCompetencyType.skill);
    _knowledge = await _repository.getAllCompetencies(competencyType: IdpCompetencyType.knowledge);
    setState(() => _loading = false);
  }

  Future<void> _addCompetency() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(IdpCompetencyType.label(_currentType)),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: _currentType == IdpCompetencyType.skill
                ? 'Masalan: Nutq so\'zlash qobiliyati'
                : 'Masalan: Soliqlarni hisoblash bilimi',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("Bekor qilish")),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Qo\'shish'),
          ),
        ],
      ),
    );
    if (name == null || name.isEmpty) return;
    await _repository.createCompetency(name, _currentType);
    _load();
  }

  Future<void> _rename(IdpCompetency c) async {
    final controller = TextEditingController(text: c.name);
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nomini o\'zgartirish'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("Bekor qilish")),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Saqlash'),
          ),
        ],
      ),
    );
    if (name == null || name.isEmpty || name == c.name) return;
    await _repository.updateCompetencyName(c.id!, name);
    _load();
  }

  Future<void> _delete(IdpCompetency c) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("O'chirish"),
        content: Text('"${c.name}" o\'chirilsinmi?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text("Yo'q")),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Ha')),
        ],
      ),
    );
    if (confirmed == true) {
      await _repository.deleteCompetency(c.id!);
      _load();
    }
  }

  Widget _list(List<IdpCompetency> items) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            "Hali qo'shilmagan. Har biri 70-20-10 modeli (amaliy rivojlanish, "
            "ustoz-shogird/feedback, training/kitob) bo'yicha rejalashtiriladi.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).hintColor),
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final c = items[i];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            title: Text(c.name),
            subtitle: LinearProgressIndicator(value: c.overallProgress),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${(c.overallProgress * 100).round()}%'),
                IconButton(icon: const Icon(Icons.edit_outlined, size: 20), onPressed: () => _rename(c)),
                IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => _delete(c)),
              ],
            ),
            onTap: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => IdpEditScreen(competency: c)),
              );
              _load();
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shaxsiy rivojlanish rejasi (IDP)'),
        bottom: TabBar(
          controller: _tabController,
          onTap: (_) => setState(() {}),
          tabs: const [
            Tab(text: 'Qobiliyatlar'),
            Tab(text: 'Bilimlar'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addCompetency,
        icon: const Icon(Icons.add),
        label: const Text('Qo\'shish'),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_list(_skills), _list(_knowledge)],
      ),
    );
  }
}
