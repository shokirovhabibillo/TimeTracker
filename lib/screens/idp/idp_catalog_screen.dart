import 'package:flutter/material.dart';

import '../../data/idp_skill_catalog.dart';
import '../../data/repositories/idp_repository.dart';

class IdpCatalogScreen extends StatefulWidget {
  const IdpCatalogScreen({super.key});

  @override
  State<IdpCatalogScreen> createState() => _IdpCatalogScreenState();
}

class _IdpCatalogScreenState extends State<IdpCatalogScreen> {
  final _repository = IdpRepository();
  final _searchController = TextEditingController();
  String? _activeCategory;
  final Set<String> _selectedIds = {};
  int _months = 6;
  bool _saving = false;

  List<IdpSkill> get _filtered {
    final query = _searchController.text.trim().toLowerCase();
    return IdpSkillCatalog.all.where((s) {
      if (_activeCategory != null && s.category != _activeCategory) return false;
      if (query.isNotEmpty && !s.name.toLowerCase().contains(query)) return false;
      return true;
    }).toList();
  }

  void _toggle(IdpSkill s) {
    setState(() {
      if (_selectedIds.contains(s.id)) {
        _selectedIds.remove(s.id);
      } else if (_selectedIds.length < 6) {
        _selectedIds.add(s.id);
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Bir vaqtda ko'pi bilan 6 ta qobiliyat tanlash mumkin.")));
      }
    });
  }

  Future<void> _generate() async {
    if (_selectedIds.isEmpty) return;
    setState(() => _saving = true);
    final selected = IdpSkillCatalog.all.where((s) => _selectedIds.contains(s.id));
    for (final s in selected) {
      await _repository.createCompetencyFromCatalog(
        name: s.name,
        goal: s.goalFor(_months),
        actions70: s.actions70,
        actions20: s.actions20,
        actions10: s.actions10,
      );
    }
    if (mounted) {
      setState(() => _saving = false);
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text("Tayyor katalogdan tanlash")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: "Qobiliyat qidirish...",
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: const Text('Barchasi'),
                    selected: _activeCategory == null,
                    onSelected: (_) => setState(() => _activeCategory = null),
                  ),
                ),
                ...IdpSkillCategory.all.map((c) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text(IdpSkillCategory.label(c)),
                        selected: _activeCategory == c,
                        onSelected: (_) => setState(() => _activeCategory = c),
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              itemCount: _filtered.length,
              itemBuilder: (context, i) {
                final s = _filtered[i];
                final selected = _selectedIds.contains(s.id);
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  color: selected ? scheme.primary.withOpacity(0.08) : null,
                  child: CheckboxListTile(
                    value: selected,
                    onChanged: (_) => _toggle(s),
                    title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(s.description, style: const TextStyle(fontSize: 12)),
                    secondary: CircleAvatar(
                      radius: 12,
                      backgroundColor: scheme.primary.withOpacity(0.12),
                      child: Text(IdpSkillCategory.label(s.category)[0],
                          style: TextStyle(fontSize: 11, color: scheme.primary)),
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, -2))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Text('Reja muddati:'),
                      const SizedBox(width: 12),
                      ...[3, 6, 12].map((m) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text('$m oy'),
                              selected: _months == m,
                              onSelected: (_) => setState(() => _months = m),
                            ),
                          )),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (_selectedIds.isEmpty || _saving) ? null : _generate,
                      child: _saving
                          ? const CircularProgressIndicator()
                          : Text("70/20/10 rejani tuzish (${_selectedIds.length} tanlangan)"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
