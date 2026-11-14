import '../model/assignment.dart';

class DeadlineService {
  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  bool isOverdue(Assignment assignment, {DateTime? today}) {
    if (assignment.isCompleted) {
      return false;
    }

    final currentDate = _dateOnly(today ?? DateTime.now());
    final dueDate = _dateOnly(assignment.dueDate);

    return dueDate.isBefore(currentDate);
  }

  bool isUrgent(
    Assignment assignment, {
    DateTime? today,
  }) {
    if (assignment.isCompleted) {
      return false;
    }

    final currentDate = _dateOnly(today ?? DateTime.now());
    final dueDate = _dateOnly(assignment.dueDate);

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
