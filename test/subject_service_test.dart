import 'package:flutter_test/flutter_test.dart';
import 'package:study_mate/model/student.dart';
import 'package:study_mate/service/assignment_service.dart';
import 'package:study_mate/service/subject_service.dart';

void main() {
  late SubjectService service;
  late AssignmentService assignmentService;
  late Student student;

  setUp(() {
    service = SubjectService();
    assignmentService = AssignmentService();
    student = Student(id: 'ST01', name: 'Student One');
  });

  group('addSubject', () {
    test('adds a subject with a valid name', () {
      final subject = service.addSubject(
        student: student,
        id: 'S01',
        name: 'Mobile Development',
      );

      expect(student.subjects, contains(subject));
      expect(subject.name, 'Mobile Development');
    });

    test('trims surrounding whitespace from the name', () {
      final subject = service.addSubject(
        student: student,
        id: 'S01',
        name: '  Mobile Development  ',
      );

      expect(subject.name, 'Mobile Development');
    });

    test('throws when the ID is empty', () {
      expect(
        () => service.addSubject(
          student: student,
          id: '  ',
          name: 'Mobile Development',
        ),
        throwsArgumentError,
      );
    });

    test('throws when the name is empty', () {
      expect(
        () => service.addSubject(
          student: student,
          id: 'S01',
          name: '   ',
        ),
        throwsArgumentError,
      );
    });

    test('throws when the ID already exists', () {
      service.addSubject(
        student: student,
        id: 'S01',
        name: 'Mobile Development',
      );

      expect(
        () => service.addSubject(
          student: student,
          id: 'S01',
          name: 'Databases',
        ),
        throwsStateError,
      );
    });

    test('throws when the name already exists (case-insensitive)', () {
      service.addSubject(
        student: student,
        id: 'S01',
        name: 'Mobile Development',
      );

      expect(
        () => service.addSubject(
          student: student,
          id: 'S02',
          name: 'mobile development',
        ),
        throwsStateError,
      );
    });
  });

  group('renameSubject', () {
    test('renames an existing subject', () {
      service.addSubject(
        student: student,
        id: 'S01',
        name: 'Mobile Development',
      );

      service.renameSubject(
        student: student,
        subjectId: 'S01',
        newName: 'Advanced Mobile Development',
      );

      expect(student.subjects.single.name, 'Advanced Mobile Development');
    });

    test('throws when the subject does not exist', () {
      expect(
        () => service.renameSubject(
          student: student,
          subjectId: 'S99',
          newName: 'New Name',
        ),
        throwsStateError,
      );
    });

    test('throws when the new name is empty', () {
      service.addSubject(
        student: student,
        id: 'S01',
        name: 'Mobile Development',
      );

      expect(
        () => service.renameSubject(
          student: student,
          subjectId: 'S01',
          newName: '   ',
        ),
        throwsArgumentError,
      );
    });

    test('throws when another subject already uses the new name', () {
      service.addSubject(
        student: student,
        id: 'S01',
        name: 'Mobile Development',
      );
      service.addSubject(
        student: student,
        id: 'S02',
        name: 'Databases',
      );

      expect(
        () => service.renameSubject(
          student: student,
          subjectId: 'S01',
          newName: 'databases',
        ),
        throwsStateError,
      );
    });

    test('allows renaming a subject to its own current name', () {
      service.addSubject(
        student: student,
        id: 'S01',
        name: 'Mobile Development',
      );

      service.renameSubject(
        student: student,
        subjectId: 'S01',
        newName: 'Mobile Development',
      );

      expect(student.subjects.single.name, 'Mobile Development');
    });
  });

  group('deleteSubject', () {
    test('deletes a subject that has no assignments', () {
      service.addSubject(
        student: student,
        id: 'S01',
        name: 'Mobile Development',
      );

      service.deleteSubject(student: student, subjectId: 'S01');

      expect(student.subjects, isEmpty);
    });

    test('throws when the subject still has assignments', () {
      final subject = service.addSubject(
        student: student,
        id: 'S01',
        name: 'Mobile Development',
      );

      assignmentService.createAssignment(
        student: student,
        id: 'A01',
        title: 'Complete Milestone 2',
        dueDate: DateTime(2026, 11, 20),
        subject: subject,
      );

      expect(
        () => service.deleteSubject(student: student, subjectId: 'S01'),
        throwsStateError,
      );
    });

    test('allows deleting a subject after its assignments are removed', () {
      final subject = service.addSubject(
        student: student,
        id: 'S01',
        name: 'Mobile Development',
      );

      assignmentService.createAssignment(
        student: student,
        id: 'A01',
        title: 'Complete Milestone 2',
        dueDate: DateTime(2026, 11, 20),
        subject: subject,
      );
      assignmentService.deleteAssignment(
        student: student,
        assignmentId: 'A01',
      );

      service.deleteSubject(student: student, subjectId: 'S01');

      expect(student.subjects, isEmpty);
    });

    test('throws when the subject does not exist', () {
      expect(
        () => service.deleteSubject(student: student, subjectId: 'S99'),
        throwsStateError,
      );
    });
  });
}
