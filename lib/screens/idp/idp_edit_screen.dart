import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/models/idp_model.dart';
import '../../data/repositories/idp_repository.dart';

class IdpEditScreen extends StatefulWidget {
  final IdpCompetency competency;
  const IdpEditScreen({super.key, required this.competency});

  @override
  State<IdpEditScreen> createState() => _IdpEditScreenState();
}

class _IdpEditScreenState extends State<IdpEditScreen> {
  final _repository = IdpRepository();
  late List<IdpActionItem> _items;

  @override
  void initState() {
    super.initState();
    _items = List.of(widget.competency.items);
  }

  Future<void> _save(int index) async {
    await _repository.updateActionItem(_items[index]);
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
    });
    _save(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.competency.name)),
      body: ListView.builder(
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
                  Text(IdpBucket.label(item.bucket),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const Divider(),
                  TextFormField(
                    initialValue: item.purpose,
                    decoration: const InputDecoration(labelText: 'Maqsad'),
                    maxLines: 2,
                    onChanged: (v) => _items[index] = item.copyWith(purpose: v),
                    onEditingComplete: () => _save(index),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: item.actionPlan,
                    decoration: const InputDecoration(labelText: "Harakat rejasi (o'lchamda)"),
                    maxLines: 3,
                    onChanged: (v) => _items[index] = item.copyWith(actionPlan: v),
                    onEditingComplete: () => _save(index),
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
                    onChanged: (v) {
                      setState(() => _items[index] = item.copyWith(status: v!));
                      _save(index);
                    },
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: item.achievedResult,
                    decoration: const InputDecoration(labelText: 'Erishilgan natija'),
                    maxLines: 2,
                    onChanged: (v) => _items[index] = item.copyWith(achievedResult: v),
                    onEditingComplete: () => _save(index),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: item.comment,
                    decoration: const InputDecoration(labelText: 'Izoh'),
                    maxLines: 2,
                    onChanged: (v) => _items[index] = item.copyWith(comment: v),
                    onEditingComplete: () => _save(index),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
