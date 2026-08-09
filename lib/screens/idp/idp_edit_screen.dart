import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/models/idp_model.dart';
import '../../data/models/task_model.dart';
import '../../data/repositories/idp_repository.dart';
import '../planner/add_task_screen.dart';

class IdpEditScreen extends StatefulWidget {
  final IdpCompetency competency;
  const IdpEditScreen({super.key, required this.competency});

  @override
  State<IdpEditScreen> createState() => _IdpEditScreenState();
}

class _IdpEditScreenState extends State<IdpEditScreen> {
  final _repository = IdpRepository();
  late List<IdpActionItem> _items;
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    _items = List.of(widget.competency.items);
  }

  Future<void> _saveAll() async {
    for (final item in _items) {
      await _repository.updateActionItem(item);
    }
    setState(() => _dirty = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saqlandi')));
    }
  }

  Future<void> _pickDate(int index, bool isStart) async {
    final current = isStart ? _items[index].startDate : _items[index].endDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      _items[index] = isStart
          ? _items[index].copyWith(startDate: picked)
          : _items[index].copyWith(endDate: picked);
      _dirty = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.competency.name),
        actions: [
          TextButton(onPressed: _saveAll, child: const Text('Saqlash')),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                final dateFmt = DateFormat('d MMM yyyy');
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(IdpBucket.label(item.bucket),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            ),
                            IconButton(
                              icon: const Icon(Icons.event_available, size: 20),
                              tooltip: "Kun jadvaliga qo'shish",
                              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => AddTaskScreen(
                                  initialDay: DateTime.now(),
                                  initialCategory: TaskCategory.idpDevelopment,
                                  initialTitle: '${widget.competency.name} — ${IdpBucket.label(item.bucket)}',
                                ),
                              )),
                            ),
                          ],
                        ),
                        const Divider(),
                        TextFormField(
                          initialValue: item.purpose,
                          decoration: InputDecoration(labelText: 'Maqsad', hintText: IdpFieldHints.purpose(item.bucket)),
                          maxLines: 2,
                          onChanged: (v) => setState(() {
                            _items[index] = item.copyWith(purpose: v);
                            _dirty = true;
                          }),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          initialValue: item.actionPlan,
                          decoration: InputDecoration(
                              labelText: "Harakat rejasi (o'lchamda)", hintText: IdpFieldHints.actionPlan(item.bucket)),
                          maxLines: 3,
                          onChanged: (v) => setState(() {
                            _items[index] = item.copyWith(actionPlan: v);
                            _dirty = true;
                          }),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => _pickDate(index, true),
                                child: Text(item.startDate != null
                                    ? 'Boshlanish: ${dateFmt.format(item.startDate!)}'
                                    : 'Boshlanish vaqti'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => _pickDate(index, false),
                                child: Text(item.endDate != null
                                    ? 'Tugash: ${dateFmt.format(item.endDate!)}'
                                    : 'Tugash vaqti'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: item.status,
                          decoration: const InputDecoration(labelText: 'Jarayon'),
                          items: IdpStatus.all
                              .map((s) => DropdownMenuItem(value: s, child: Text(IdpStatus.label(s))))
                              .toList(),
                          onChanged: (v) => setState(() {
                            _items[index] = item.copyWith(status: v!);
                            _dirty = true;
                          }),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          initialValue: item.achievedResult,
                          decoration: InputDecoration(labelText: 'Erishilgan natija', hintText: IdpFieldHints.achievedResult()),
                          maxLines: 2,
                          onChanged: (v) => setState(() {
                            _items[index] = item.copyWith(achievedResult: v);
                            _dirty = true;
                          }),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          initialValue: item.comment,
                          decoration: InputDecoration(labelText: 'Izoh', hintText: IdpFieldHints.comment()),
                          maxLines: 2,
                          onChanged: (v) => setState(() {
                            _items[index] = item.copyWith(comment: v);
                            _dirty = true;
                          }),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: ElevatedButton.icon(
                onPressed: _dirty ? _saveAll : null,
                icon: const Icon(Icons.save),
                label: const Text('Barchasini saqlash'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
