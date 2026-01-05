import 'package:cloud_firestore/cloud_firestore.dart';

class DietHistory {
  final String id;
  final String groupId;
  final DateTime date;
  final int status; // 1 = grün (nein), 2 = gelb (neutral), 3 = rot (ja), 0 = keine Angabe
  final DateTime createdAt;
  final List<String> triggers;
  final String notes;

  DietHistory({
    required this.id,
    required this.groupId,
    required this.date,
    required this.status,
    required this.createdAt,
    required this.triggers,
    required this.notes,
  });

  DietHistory copyWith({
    String? id,
    String? groupId,
    DateTime? date,
    int? status,
    DateTime? createdAt,
    List<String>? triggers,
    String? notes,
  }) {
    return DietHistory(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      date: date ?? this.date,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      triggers: triggers ?? this.triggers,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'groupId': groupId,
      'date': Timestamp.fromDate(date),
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'triggers': triggers,
      'notes': notes,
    };
  }

  factory DietHistory.fromMap(Map<String, dynamic> map) {
    return DietHistory(
      id: map['id'] ?? '',
      groupId: map['groupId'] ?? '',
        date: map['date'] is Timestamp
          ? (map['date'] as Timestamp).toDate()
          : map['date'] is DateTime
            ? map['date']
            : DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
      status: map['status'] ?? 0,
        createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : map['createdAt'] is DateTime
            ? map['createdAt']
            : DateTime.parse(
              map['createdAt'] ?? DateTime.now().toIso8601String()),
      triggers: (map['triggers'] is List)
          ? List<String>.from((map['triggers'] as List).whereType<String>())
          : <String>[],
      notes: map['notes'] ?? '',
    );
  }

  @override
  String toString() =>
      'DietHistory(id: $id, groupId: $groupId, date: $date, status: $status, createdAt: $createdAt, triggers: $triggers, notes: $notes)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DietHistory &&
        other.id == id &&
        other.groupId == groupId &&
        other.date == date &&
        other.status == status &&
          other.createdAt == createdAt &&
        other.triggers == triggers &&
        other.notes == notes;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      groupId.hashCode ^
      date.hashCode ^
      status.hashCode ^
      createdAt.hashCode ^
      triggers.hashCode;
}
