import 'subject.dart';
import 'assignment.dart';

class Student {
  final String id;
  String name;
  final List<Subject> subjects;
  final List<Assignment> assignments;

  Student({
    required this.id,
    required this.name,
    List<Subject>? subjects,
    List<Assignment>? assignments,
  })  : subjects = subjects ?? [],
        assignments = assignments ?? [];

  void addSubject(Subject subject) {
    subjects.add(subject);
  }

  void addAssignment(Assignment assignment) {
    assignments.add(assignment);
  }

  int get totalAssignments {
    return assignments.length;
  }
}
