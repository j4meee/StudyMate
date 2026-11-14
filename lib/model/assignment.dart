import 'subject.dart';

enum Priority {
  low,
  medium,
  high
}

enum AssignmentStatus {
  pending,
  completed
}

class Assignment {
  final String id;
  String title;
  DateTime dueDate;
  Priority priority;
  AssignmentStatus status;
  Subject subject;

  Assignment({
    required this.id,
    required this.title,
    required this.dueDate,
    required this.subject,
    this.priority = Priority.medium,
    this.status = AssignmentStatus.pending
  });

  void markCompleted(){
    status = AssignmentStatus.completed;
  }

  void markPending(){
    status = AssignmentStatus.pending;
  }

  bool get isCompleted {
    return status == AssignmentStatus.completed;
  }
}

