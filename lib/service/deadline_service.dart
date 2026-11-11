import '../model/assignment.dart';

class DeadlineService {
  bool isOverdue(Assignment assignment, {DateTime? today}) {
    if (assignment.isCompleted) {
      return false;
    }

    final now = today ?? DateTime.now();

    final currentDate = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final dueDate = DateTime(
      assignment.dueDate.year,
      assignment.dueDate.month,
      assignment.dueDate.day,
    );

    return dueDate.isBefore(currentDate);
  }

  bool isUrgent(
    Assignment assignment, {
    DateTime? today,
  }) {
    if (assignment.isCompleted) {
      return false;
    }

    final now = today ?? DateTime.now();

    final currentDate = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final dueDate = DateTime(
      assignment.dueDate.year,
      assignment.dueDate.month,
      assignment.dueDate.day,
    );

    final lastUrgentDate = DateTime(
      currentDate.year,
      currentDate.month,
      currentDate.day + 2,
    );

    return !dueDate.isBefore(currentDate) &&
        !dueDate.isAfter(lastUrgentDate);
  }

  List<Assignment> getOverdueAssignments(
    List<Assignment> assignments, {
    DateTime? today,
  }) {
    return assignments
        .where((a) => isOverdue(a, today: today))
        .toList();
  }

  List<Assignment> getUrgentAssignments(
    List<Assignment> assignments, {
    DateTime? today,
  }) {
    return assignments
        .where((a) => isUrgent(a, today: today))
        .toList();
  }
}
