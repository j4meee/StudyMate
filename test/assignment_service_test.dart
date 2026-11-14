import 'package:flutter_test/flutter_test.dart';
import 'package:study_mate/model/assignment.dart';
import 'package:study_mate/model/student.dart';
import 'package:study_mate/model/subject.dart';
import 'package:study_mate/service/assignment_service.dart';
import 'package:study_mate/service/subject_service.dart';

void main() {
  late AssignmentService service;
  late SubjectService subjectService;
  late Student student;
  late Subject subject;

  setUp(() {
    service = AssignmentService();
    subjectService = SubjectService();
    student = Student(id: 'ST01', name: 'Student One');
    subject = subjectService.addSubject(
      student: student,
      id: 'S01',
      name: 'Mobile Development',
    );
  });

  Assignment createAssignment({
    String id = 'A01',
    String title = 'Complete Milestone 2',
  }) {
    return service.createAssignment(
      student: student,
      id: id,
      title: title,
      dueDate: DateTime(2026, 11, 20),
      subject: subject,
    );
  }

  group('createAssignment', () {
    test('creates and stores a pending assignment for the student', () {
      final assignment = createAssignment();

      expect(student.assignments, contains(assignment));
      expect(assignment.title, 'Complete Milestone 2');
      expect(assignment.status, AssignmentStatus.pending);
      expect(assignment.subject, same(subject));
      expect(student.totalAssignments, 1);
    });

    test('trims surrounding whitespace from the title', () {
      final assignment = createAssignment(title: '  Complete Milestone 2  ');

      expect(assignment.title, 'Complete Milestone 2');
    });

    test('throws when the title is empty', () {
      expect(
        () => createAssignment(title: '   '),
        throwsArgumentError,
      );
    });

    test('throws when the ID is empty', () {
      expect(
        () => createAssignment(id: '  '),
        throwsArgumentError,
      );
    });

    test('throws when the assignment ID already exists', () {
      createAssignment();

      expect(
        () => createAssignment(title: 'Another task'),
        throwsStateError,
      );
    });

    test('throws when the subject belongs to another student', () {
      final otherStudent = Student(id: 'ST02', name: 'Student Two');
      final otherSubject = subjectService.addSubject(
        student: otherStudent,
        id: 'S02',
        name: 'Databases',
      );

      expect(
        () => service.createAssignment(
          student: student,
          id: 'A02',
          title: 'Wrong owner',
          dueDate: DateTime(2026, 11, 20),
          subject: otherSubject,
        ),
        throwsStateError,
      );
    });
  });

  group('editAssignment', () {
    test('updates title, due date, priority and subject', () {
      final assignment = createAssignment();
      final otherSubject = subjectService.addSubject(
        student: student,
        id: 'S02',
        name: 'Databases',
      );

      service.editAssignment(
        student: student,
        assignmentId: 'A01',
        title: 'Updated title',
        dueDate: DateTime(2026, 12, 1),
        subject: otherSubject,
        priority: Priority.high,
      );

      expect(assignment.title, 'Updated title');
      expect(assignment.dueDate, DateTime(2026, 12, 1));
      expect(assignment.subject, same(otherSubject));
      expect(assignment.priority, Priority.high);
    });

    test('keeps the status unchanged when editing', () {
      createAssignment();
      service.updateStatus(
        student: student,
        assignmentId: 'A01',
        status: AssignmentStatus.completed,
      );

      service.editAssignment(
        student: student,
        assignmentId: 'A01',
        title: 'Updated title',
        dueDate: DateTime(2026, 12, 1),
        subject: subject,
      );

      expect(
        student.assignments.single.status,
        AssignmentStatus.completed,
      );
    });

    test('throws when the assignment does not exist', () {
      expect(
        () => service.editAssignment(
          student: student,
          assignmentId: 'A99',
          title: 'Updated title',
          dueDate: DateTime(2026, 12, 1),
          subject: subject,
        ),
        throwsStateError,
      );
    });

    test('throws when the new title is empty', () {
      createAssignment();

      expect(
        () => service.editAssignment(
          student: student,
          assignmentId: 'A01',
          title: '   ',
          dueDate: DateTime(2026, 12, 1),
          subject: subject,
        ),
        throwsArgumentError,
      );
    });

    test('throws when the new subject does not belong to the student', () {
      createAssignment();
      final otherStudent = Student(id: 'ST02', name: 'Student Two');
      final otherSubject = subjectService.addSubject(
        student: otherStudent,
        id: 'S02',
        name: 'Databases',
      );

      expect(
        () => service.editAssignment(
          student: student,
          assignmentId: 'A01',
          title: 'Updated title',
          dueDate: DateTime(2026, 12, 1),
          subject: otherSubject,
        ),
        throwsStateError,
      );
    });
  });

  group('updateStatus', () {
    test('marks a pending assignment as completed', () {
      createAssignment();

      service.updateStatus(
        student: student,
        assignmentId: 'A01',
        status: AssignmentStatus.completed,
      );

      expect(
        student.assignments.single.status,
        AssignmentStatus.completed,
      );
    });

    test('marks a completed assignment as pending again', () {
      createAssignment();

      service.updateStatus(
        student: student,
        assignmentId: 'A01',
        status: AssignmentStatus.completed,
      );
      service.updateStatus(
        student: student,
        assignmentId: 'A01',
        status: AssignmentStatus.pending,
      );

      expect(
        student.assignments.single.status,
        AssignmentStatus.pending,
      );
    });

    test('throws when the assignment does not exist', () {
      expect(
        () => service.updateStatus(
          student: student,
          assignmentId: 'A99',
          status: AssignmentStatus.completed,
        ),
        throwsStateError,
      );
    });
  });

  group('deleteAssignment', () {
    test('removes the assignment from the student', () {
      createAssignment();

      service.deleteAssignment(student: student, assignmentId: 'A01');

      expect(student.assignments, isEmpty);
    });

    test('only removes the targeted assignment', () {
      createAssignment(id: 'A01');
      createAssignment(id: 'A02');

      service.deleteAssignment(student: student, assignmentId: 'A01');

      expect(student.assignments.length, 1);
      expect(student.assignments.single.id, 'A02');
    });

    test('throws when the assignment does not exist', () {
      expect(
        () => service.deleteAssignment(student: student, assignmentId: 'A99'),
        throwsStateError,
      );
    });
  });
}
