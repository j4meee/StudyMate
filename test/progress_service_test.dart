import 'package:flutter_test/flutter_test.dart';
import 'package:study_mate/model/assignment.dart';
import 'package:study_mate/model/student.dart';
import 'package:study_mate/model/subject.dart';
import 'package:study_mate/service/progress_service.dart';

void main() {
  final service = ProgressService();

  Student newStudent({int total = 0, int completed = 0}) {
    final student = Student(id: 'ST01', name: 'Student One');
    final subject = Subject(id: 'S01', name: 'Mobile Development');

    for (var i = 0; i < total; i++) {
      student.addAssignment(
        Assignment(
          id: 'A${i.toString().padLeft(2, '0')}',
          title: 'Assignment ${i + 1}',
          dueDate: DateTime(2026, 11, 20),
          subject: subject,
          status: i < completed
              ? AssignmentStatus.completed
              : AssignmentStatus.pending,
        ),
      );
    }

    return student;
  }

  group('calculateProgress', () {
    test('reports 0% when the student has no assignments (boundary)', () {
      final summary = service.calculateProgress(newStudent());

      expect(summary.total, 0);
      expect(summary.completed, 0);
      expect(summary.pending, 0);
      expect(summary.percentage, 0.0);
    });

    test('counts completed and pending assignments correctly', () {
      final summary = service.calculateProgress(
        newStudent(total: 4, completed: 1),
      );

      expect(summary.total, 4);
      expect(summary.completed, 1);
      expect(summary.pending, 3);
      expect(summary.percentage, 25.0);
    });

    test('reports 100% when every assignment is completed (boundary)', () {
      final summary = service.calculateProgress(
        newStudent(total: 3, completed: 3),
      );

      expect(summary.completed, 3);
      expect(summary.pending, 0);
      expect(summary.percentage, 100.0);
    });

    test('updates when an assignment status changes', () {
      final student = newStudent(total: 2, completed: 0);

      final before = service.calculateProgress(student);
      expect(before.percentage, 0.0);

      student.assignments.first.markCompleted();
      final after = service.calculateProgress(student);

      expect(after.completed, 1);
      expect(after.pending, 1);
      expect(after.percentage, 50.0);
    });

    test('updates when an assignment is deleted', () {
      final student = newStudent(total: 4, completed: 2);

      //Remove one completed assignment.
      student.assignments.removeAt(0);

      final summary = service.calculateProgress(student);

      expect(summary.total, 3);
      expect(summary.completed, 1);
      expect(summary.pending, 2);
      expect(summary.percentage, closeTo(33.33, 0.01));
    });
  });
}
