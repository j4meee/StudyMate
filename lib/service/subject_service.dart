import '../model/student.dart';
import '../model/subject.dart';

class SubjectService {
  Subject addSubject({
    required Student student,
    required String id,
    required String name,
  }) {
    final cleanName = name.trim();

    if (id.trim().isEmpty) {
      throw ArgumentError('Subject ID cannot be empty');
    }

    if (cleanName.isEmpty) {
      throw ArgumentError('Subject name cannot be empty');
    }

    if (student.subjects.any((s) => s.id == id)) {
      throw StateError('Subject ID already exists');
    }

    if (student.subjects.any(
      (s) => s.name.toLowerCase() == cleanName.toLowerCase(),
    )) {
      throw StateError('Subject name already exists');
    }

    final subject = Subject(
      id: id,
      name: cleanName,
    );

    student.addSubject(subject);

    return subject;
  }

  void renameSubject({
    required Student student,
    required String subjectId,
    required String newName,
  }) {
    final cleanName = newName.trim();

    if (cleanName.isEmpty) {
      throw ArgumentError('Subject name cannot be empty');
    }

    final subject = student.subjects.firstWhere(
      (s) => s.id == subjectId,
      orElse: () => throw StateError('Subject not found'),
    );

    final duplicate = student.subjects.any(
      (s) =>
          s.id != subjectId &&
          s.name.toLowerCase() == cleanName.toLowerCase(),
    );

    if (duplicate) {
      throw StateError('Subject name already exists');
    }

    subject.rename(cleanName);
  }

  void deleteSubject({
    required Student student,
    required String subjectId,
  }) {
    final index = student.subjects.indexWhere(
      (s) => s.id == subjectId,
    );

    if (index == -1) {
      throw StateError('Subject not found');
    }

    final subject = student.subjects[index];

    //Prevent deleting a subject still used by assignments
    if (student.assignments.any(
      (a) => identical(a.subject, subject),
    )) {
      throw StateError('Subject still has assignments');
    }

    student.subjects.removeAt(index);
  }
}
