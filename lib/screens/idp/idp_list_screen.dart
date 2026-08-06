import 'package:flutter/material.dart';

import '../../data/models/idp_model.dart';
import '../../data/repositories/idp_repository.dart';
import 'idp_edit_screen.dart';

class IdpListScreen extends StatefulWidget {
  const IdpListScreen({super.key});

  @override
  State<IdpListScreen> createState() => _IdpListScreenState();
}

class _IdpListScreenState extends State<IdpListScreen> {
  final _repository = IdpRepository();
  List<IdpCompetency> _competencies = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    _competencies = await _repository.getAllCompetencies();
    setState(() => _loading = false);
  }

  Future<void> _addCompetency() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yangi qobiliyat'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Masalan: Nizoli vaziyatlarni boshqarish'),
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
    await _repository.createCompetency(name);
    _load();
  }

  Future<void> _delete(IdpCompetency c) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Qobiliyatni o'chirish"),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shaxsiy rivojlanish rejasi (IDP)')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addCompetency,
        icon: const Icon(Icons.add),
        label: const Text('Qobiliyat qo\'shish'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _competencies.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      "Hali qobiliyat qo'shilmagan. Har bir qobiliyat 70-20-10 "
                      "modeli (ish joyida rivojlanish, ustoz-shogird/feedback, "
                      "training/kitob) bo'yicha rejalashtiriladi.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Theme.of(context).hintColor),
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
                  itemCount: _competencies.length,
                  itemBuilder: (context, i) {
                    final c = _competencies[i];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        title: Text(c.name),
                        subtitle: LinearProgressIndicator(value: c.overallProgress),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('${(c.overallProgress * 100).round()}%'),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => _delete(c),
                            ),
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
                ),
    );
  }
}
