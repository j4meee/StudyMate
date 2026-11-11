import '../model/assignment.dart';
import '../model/student.dart';

class ProgressSummary {
  final int total;
  final int completed;
  final int pending;
  final double percentage;

  const ProgressSummary({
    required this.total,
    required this.completed,
    required this.pending,
    required this.percentage,
  });
}

class ProgressService {
  ProgressSummary calculateProgress(Student student) {
    final total = student.assignments.length;

    final completed = student.assignments
        .where((a) => a.status == AssignmentStatus.completed)
        .length;

    final pending = student.assignments
        .where((a) => a.status == AssignmentStatus.pending)
        .length;

    final percentage = total == 0
        ? 0.0
        : (completed / total) * 100;

    return ProgressSummary(
      total: total,
      completed: completed,
      pending: pending,
      percentage: percentage,
    );
  }
}
