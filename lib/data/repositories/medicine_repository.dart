import '../database/database_helper.dart';
import '../models/medicine_model.dart';

class MedicineRepository {
  final _dbHelper = DatabaseHelper.instance;

  String _dateKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<int> createMedicine(Medicine m) async {
    final db = await _dbHelper.database;
    return db.insert('medicines', m.toMap()..remove('id'));
  }

  Future<void> updateMedicine(Medicine m) async {
    final db = await _dbHelper.database;
    await db.update('medicines', m.toMap(), where: 'id = ?', whereArgs: [m.id]);
  }

  Future<void> deleteMedicine(int id) async {
    final db = await _dbHelper.database;
    await db.delete('dose_logs', where: 'medicine_id = ?', whereArgs: [id]);
    await db.delete('medicines', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Medicine>> getAllMedicines() async {
    final db = await _dbHelper.database;
    final rows = await db.query('medicines', orderBy: 'name ASC');
    return rows.map(Medicine.fromMap).toList();
  }

  /// Medicines that are active (started, and not past their end date) on [day].
  Future<List<Medicine>> getActiveMedicinesForDay(DateTime day) async {
    final all = await getAllMedicines();
    final dayOnly = DateTime(day.year, day.month, day.day);
    return all.where((m) {
      final start = DateTime(m.startDate.year, m.startDate.month, m.startDate.day);
      if (dayOnly.isBefore(start)) return false;
      if (m.endDate != null) {
        final end = DateTime(m.endDate!.year, m.endDate!.month, m.endDate!.day);
        if (dayOnly.isAfter(end)) return false;
      }
      return true;
    }).toList();
  }

  Future<bool> isDoseTaken(int medicineId, DateTime day, String time) async {
    final db = await _dbHelper.database;
    final rows = await db.query('dose_logs',
        where: 'medicine_id = ? AND date = ? AND time = ?',
        whereArgs: [medicineId, _dateKey(day), time],
        limit: 1);
    if (rows.isEmpty) return false;
    return (rows.first['taken'] as int) == 1;
  }

  Future<Set<String>> getTakenDoseKeys(DateTime day) async {
    final db = await _dbHelper.database;
    final rows = await db.query('dose_logs', where: 'date = ? AND taken = 1', whereArgs: [_dateKey(day)]);
    return rows.map((r) => '${r['medicine_id']}_${r['time']}').toSet();
  }

  Future<void> setDoseTaken(int medicineId, DateTime day, String time, bool taken) async {
    final db = await _dbHelper.database;
    final dateKey = _dateKey(day);
    final rows = await db.query('dose_logs',
        where: 'medicine_id = ? AND date = ? AND time = ?', whereArgs: [medicineId, dateKey, time], limit: 1);
    if (rows.isEmpty) {
      await db.insert('dose_logs', {'medicine_id': medicineId, 'date': dateKey, 'time': time, 'taken': taken ? 1 : 0});
    } else {
      await db.update('dose_logs', {'taken': taken ? 1 : 0}, where: 'id = ?', whereArgs: [rows.first['id']]);
    }
  }
}
