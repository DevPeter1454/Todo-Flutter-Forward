import 'dart:convert';

class Task {
  String title;
  bool isCompleted;
  bool isDeleted;

  Task({required this.title, this.isCompleted = false, this.isDeleted = false});


  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'title': title,
      'isCompleted': isCompleted,
      'isDeleted': isDeleted,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      title: map['title'] as String,
      isCompleted: map['isCompleted'] as bool,
      isDeleted: map['isDeleted'] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory Task.fromJson(String source) => Task.fromMap(json.decode(source) as Map<String, dynamic>);
}
