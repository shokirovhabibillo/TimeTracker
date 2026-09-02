import '../data/repositories/focus_session_repository.dart';
import '../data/repositories/medicine_repository.dart';
import '../data/repositories/step_repository.dart';
import '../data/repositories/task_repository.dart';

/// A single 0..100 "how was this day overall" score, blended from every
/// signal we track — not just plan completion. Weights (reasoning):
///   50% plan completion — still the primary signal, most intentional.
///   25% steps, capped at an 8000-step goal.
///   25% focus minutes, capped at a 45-minute goal.
///   +5 bonus (capped at 100) if any medicine dose was taken that day.
/// Distraction time isn't penalized separately since it already shows
/// up indirectly (low completion), and this keeps the formula legible
/// rather than double-counting the same underlying behavior.
class DailyActivityScore {
  final double value; // 0..100
  final int completedTasks;
  final int totalTasks;
  final int steps;
  final int focusMinutes;
  final bool medicineTaken;

  DailyActivityScore({
    required this.value,
    required this.completedTasks,
    required this.totalTasks,
    required this.steps,
    required this.focusMinutes,
    required this.medicineTaken,
  });

  static const stepsGoal = 8000;
  static const focusGoalMinutes = 45;

  static DailyActivityScore compute({
    required int completedTasks,
    required int totalTasks,
    required int steps,
    required int focusMinutes,
    required bool medicineTaken,
  }) {
    final completionPct = totalTasks > 0 ? completedTasks / totalTasks : 0.0;
    final stepsPct = (steps / stepsGoal).clamp(0.0, 1.0);
    final focusPct = (focusMinutes / focusGoalMinutes).clamp(0.0, 1.0);

    double score = (completionPct * 50) + (stepsPct * 25) + (focusPct * 25);
    if (medicineTaken) score += 5;
    score = score.clamp(0.0, 100.0);

    return DailyActivityScore(
      value: score,
      completedTasks: completedTasks,
      totalTasks: totalTasks,
      steps: steps,
      focusMinutes: focusMinutes,
      medicineTaken: medicineTaken,
    );
  }
}

class DailyActivityScoreService {
  final _taskRepository = TaskRepository();
  final _stepRepository = StepRepository();
  final _focusRepository = FocusSessionRepository();
  final _medicineRepository = MedicineRepository();

  String _dateKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// Scores for every day in [month] — used to color the monthly
  /// calendar by overall activity rather than plan completion alone.
  Future<Map<String, DailyActivityScore>> getMonthlyScores(DateTime month) async {
    final completionSummary = await _taskRepository.getMonthlyCompletionSummary(month);
    final result = <String, DailyActivityScore>{};
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;

    for (int d = 1; d <= daysInMonth; d++) {
      final day = DateTime(month.year, month.month, d);
      final key = _dateKey(day);
      final completion = completionSummary[key];

      final stepLog = await _stepRepository.getLogForDay(day);
      final focusSeconds = await _focusRepository.getTotalCompletedSecondsForDay(day);
      final takenDoses = await _medicineRepository.getTakenDoseKeys(day);

      result[key] = DailyActivityScore.compute(
        completedTasks: completion?.completed ?? 0,
        totalTasks: completion?.total ?? 0,
        steps: stepLog.todaySteps,
        focusMinutes: (focusSeconds / 60).round(),
        medicineTaken: takenDoses.isNotEmpty,
      );
    }
    return result;
  }
}
