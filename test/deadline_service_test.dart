import 'package:flutter_test/flutter_test.dart';
import 'package:study_mate/model/assignment.dart';
import 'package:study_mate/model/subject.dart';
import 'package:study_mate/service/deadline_service.dart';

void main() {
  final service = DeadlineService();

  //Fixed "today" so the tests are deterministic.
  final today = DateTime(2026, 11, 12);

  Assignment newAssignment({
    required DateTime dueDate,
    AssignmentStatus status = AssignmentStatus.pending,
  }) {
    return Assignment(
      id: 'A01',
      title: 'Complete Milestone 2',
      dueDate: dueDate,
      subject: Subject(id: 'S01', name: 'Mobile Development'),
      status: status,
    );
  }

  group('isOverdue', () {
    test('a pending assignment due yesterday is overdue', () {
      final assignment = newAssignment(dueDate: DateTime(2026, 11, 11));

      expect(service.isOverdue(assignment, today: today), isTrue);
    });

    test('a pending assignment due today is not overdue (boundary)', () {
      final assignment = newAssignment(dueDate: DateTime(2026, 11, 12));

      expect(service.isOverdue(assignment, today: today), isFalse);
    });

    test('a pending assignment due in the future is not overdue', () {
      final assignment = newAssignment(dueDate: DateTime(2026, 11, 20));

      expect(service.isOverdue(assignment, today: today), isFalse);
    });

    test('a completed assignment is never overdue', () {
      final assignment = newAssignment(
        dueDate: DateTime(2026, 11, 11),
        status: AssignmentStatus.completed,
      );

      expect(service.isOverdue(assignment, today: today), isFalse);
    });

    test('only the date matters, not the time of day (boundary)', () {
      final assignment = newAssignment(
        dueDate: DateTime(2026, 11, 12, 23, 59),
      );

      expect(
        service.isOverdue(assignment, today: DateTime(2026, 11, 12, 8, 30)),
        isFalse,
      );
    });
  });

  group('isUrgent', () {
    test('a pending assignment due today is urgent (boundary)', () {
      final assignment = newAssignment(dueDate: DateTime(2026, 11, 12));

      expect(service.isUrgent(assignment, today: today), isTrue);
    });

    test('a pending assignment due tomorrow is urgent', () {
      final assignment = newAssignment(dueDate: DateTime(2026, 11, 13));

      expect(service.isUrgent(assignment, today: today), isTrue);
    });

    test('a pending assignment due in two days is urgent (upper boundary)', () {
      final assignment = newAssignment(dueDate: DateTime(2026, 11, 14));

      expect(service.isUrgent(assignment, today: today), isTrue);
    });

    test('a pending assignment due in three days is not urgent', () {
      final assignment = newAssignment(dueDate: DateTime(2026, 11, 15));

      expect(service.isUrgent(assignment, today: today), isFalse);
    });

    test('an overdue assignment is not urgent', () {
      final assignment = newAssignment(dueDate: DateTime(2026, 11, 10));

      expect(service.isUrgent(assignment, today: today), isFalse);
    });

    test('a completed assignment is never urgent', () {
      final assignment = newAssignment(
        dueDate: DateTime(2026, 11, 12),
        status: AssignmentStatus.completed,
      );

      expect(service.isUrgent(assignment, today: today), isFalse);
    });
  });

  group('getOverdueAssignments', () {
    test('returns only pending assignments with a past due date', () {
      final assignments = [
        newAssignment(dueDate: DateTime(2026, 11, 10)), // overdue
        newAssignment(
          dueDate: DateTime(2026, 11, 10),
          status: AssignmentStatus.completed,
        ), // completed, excluded
        newAssignment(dueDate: DateTime(2026, 11, 13)), // urgent, excluded
        newAssignment(dueDate: DateTime(2026, 11, 25)), // future, excluded
      ];

      final overdue = service.getOverdueAssignments(
        assignments,
        today: today,
      );

      expect(overdue.length, 1);
      expect(overdue.single.dueDate, DateTime(2026, 11, 10));
      expect(overdue.single.status, AssignmentStatus.pending);
    });

    test('returns an empty list when nothing is overdue', () {
      final assignments = [
        newAssignment(dueDate: DateTime(2026, 11, 13)),
        newAssignment(dueDate: DateTime(2026, 11, 25)),
      ];

      expect(
        service.getOverdueAssignments(assignments, today: today),
        isEmpty,
      );
    });
  });

  group('getUrgentAssignments', () {
    test('returns only pending assignments due within two days', () {
      final assignments = [
        newAssignment(dueDate: DateTime(2026, 11, 12)), // urgent
        newAssignment(dueDate: DateTime(2026, 11, 14)), // urgent
        newAssignment(dueDate: DateTime(2026, 11, 10)), // overdue, excluded
        newAssignment(dueDate: DateTime(2026, 11, 15)), // future, excluded
        newAssignment(
          dueDate: DateTime(2026, 11, 13),
          status: AssignmentStatus.completed,
        ), // completed, excluded
      ];

      final urgent = service.getUrgentAssignments(assignments, today: today);

      expect(urgent.length, 2);
      expect(
        urgent.every((a) => a.dueDate.isBefore(DateTime(2026, 11, 15))),
        isTrue,
      );
    });

    test('returns an empty list when nothing is urgent', () {
      final assignments = [
        newAssignment(dueDate: DateTime(2026, 11, 10)),
        newAssignment(dueDate: DateTime(2026, 11, 25)),
      ];

      expect(
        service.getUrgentAssignments(assignments, today: today),
        isEmpty,
      );
    });
  });
}
