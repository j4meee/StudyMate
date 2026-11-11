class Subject {
  final String id;
  String name;

  Subject({required this.id, required this.name});

  void rename(String newName){
    name = newName;
  }
}