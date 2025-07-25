import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum Priority {
  low("niedrig", "low"),
  medium("mittel", "middle"),
  high("hoch", "high");

  const Priority(this.german, this.english);

  final String german;
  final String english;
}

enum TodoIcon {
  sport(Icons.sports),
  food(Icons.dining),
  meeting(Icons.group),
  pets(Icons.pets),
  doctor(Icons.medical_information),
  shopping(Icons.shopping_cart);

  const TodoIcon(this.icon);

  final IconData icon;
}

class Todo {
  final String id;
  final String groupId;
  final String title;
  final String description;
  final Priority priority;
  final Color color;
  bool isDone;
  final DateTime dueDate;
  final TodoIcon icon;

  Todo({
    required this.id,
    required this.groupId,
    required this.title,
    required this.description,
    required this.priority,
    required this.color,
    required this.isDone,
    required this.dueDate,
    required this.icon,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'groupId': groupId,
      'title': title,
      'description': description,
      'priority': priority.name,
      'color': color.toARGB32(),
      'isDone': isDone,
      'dueDate': dueDate,
      'icon': icon.name,
    };
  }

  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'],
      groupId: map['groupId'],
      title: map['title'],
      description: map['description'],
      priority: Priority.values.byName(map['priority']),
      color: Color(map['color']),
      isDone: map['isDone'],
      dueDate: (map['dueDate'] as Timestamp).toDate(),
      icon: TodoIcon.values.byName(map['icon']),
    );
  }
}
