import '../model/assignment.dart';
import '../model/student.dart';
import '../model/subject.dart';

class AssignmentService {
  Assignment createAssignment({
    required Student student,
    required String id,
    required String title,
    required DateTime dueDate,
    required Subject subject,
    Priority priority = Priority.medium,
  }) {
    //Title must not be empty
    if (title.trim().isEmpty) {
      throw ArgumentError('Assignment title cannot be empty');
    }

    //ID must not be empty
    if (id.trim().isEmpty) {
      throw ArgumentError('Assignment ID cannot be empty');
    }

    //Assignment IDs must be unique
    if (student.assignments.any((a) => a.id == id)) {
      throw StateError('Assignment ID already exists');
    }

    //Subject must belong to student
    if (!student.subjects.any((s) => identical(s, subject))) {
      throw StateError('Subject does not belong to student');
    }

    //Create model object
    final assignment = Assignment(
      id: id,
      title: title.trim(),
      dueDate: dueDate,
      subject: subject,
      priority: priority,
    );

    //Add new assignment to the student
    student.addAssignment(assignment);

    return assignment;
  }

  void updateStatus({
    required Student student,
    required String assignmentId,
    required AssignmentStatus status,
  }) {
    final assignment = student.assignments.firstWhere(
      (a) => a.id == assignmentId,
      orElse: () => throw StateError('Assignment not found'),
    );

    assignment.status = status;
  }

  void deleteAssignment({
    required Student student,
    required String assignmentId,
  }) {
    final index = student.assignments.indexWhere(
      (a) => a.id == assignmentId,
    );

    if (index == -1) {
      throw StateError('Assignment not found');
    }

    student.assignments.removeAt(index);
  }
}
