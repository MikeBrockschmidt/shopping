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
      'color': '#${color.value.toRadixString(16).padLeft(8, '0')}',
      'isDone': isDone,
      'dueDate': dueDate,
      'icon': icon.name,
    };
  }

  factory Todo.fromMap(Map<String, dynamic> map) {
    Color parseColor(dynamic colorValue) {
      if (colorValue is String) {
        // Hex-String: '#AARRGGBB' oder '#RRGGBB'
        final hexString = colorValue.replaceFirst('#', '');
        if (hexString.length == 8) {
          return Color(int.parse('0x$hexString'));
        } else if (hexString.length == 6) {
          return Color(int.parse('0xFF$hexString'));
        }
      } else if (colorValue is int) {
        // Direkter Integer-Wert (für alte Daten)
        return Color(colorValue);
      }
      return Color(0xFF0000FF); // Fallback zu Blau
    }

    return Todo(
      id: map['id'],
      groupId: map['groupId'],
      title: map['title'],
      description: map['description'],
      priority: Priority.values.byName(map['priority']),
      color: parseColor(map['color']),
      isDone: map['isDone'],
      dueDate: (map['dueDate'] as Timestamp).toDate(),
      icon: TodoIcon.values.byName(map['icon']),
    );
  }
}
