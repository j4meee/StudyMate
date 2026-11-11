
import 'model/assignment.dart';
import 'model/student.dart';
import 'service/assignment_service.dart';
import 'service/subject_service.dart';
import 'service/deadline_service.dart';
import 'service/progress_service.dart';

void main() {
  // Step 1: Create a student.
  final student = Student(
    id: 'ST01',
    name: 'Student One',
  );

  // Step 2: Create the services.
  final subjectService = SubjectService();
  final assignmentService = AssignmentService();
  final deadlineService = DeadlineService();
  final progressService = ProgressService();

  // Step 3: Add a subject.
  final subject = subjectService.addSubject(
    student: student,
    id: 'S01',
    name: 'Mobile Development',
  );

  // Step 4: Create an assignment.
  final assignment = assignmentService.createAssignment(
    student: student,
    id: 'A01',
    title: 'Complete Milestone 2',
    dueDate: DateTime(2026, 11, 13),
    subject: subject,
    priority: Priority.high,
  );

  // Step 5: Check deadline.
  print('Urgent: ${deadlineService.isUrgent(
    assignment,
    today: DateTime(2026, 11, 12),
  )}');

  // Step 6: Calculate progress.
  var progress = progressService.calculateProgress(student);
  print('Initial progress: ${progress.percentage}%');

  // Step 7: Complete the assignment.
  assignmentService.updateStatus(
    student: student,
    assignmentId: 'A01',
    status: AssignmentStatus.completed,
  );

  // Step 8: Recalculate progress.
  progress = progressService.calculateProgress(student);
  print('Final progress: ${progress.percentage}%');

  print('Completed: ${progress.completed}');
  print('Pending: ${progress.pending}');
}
