import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

@immutable
class Medication {
  final String id;
  final String groupId;
  final String name;
  final String frequency; // 'daily' | 'weekly'
  final int? weekday; // 1-7 (Mo-So), only for 'weekly'

  const Medication({
    required this.id,
    required this.groupId,
    required this.name,
    required this.frequency,
    this.weekday,
  });

  Medication copyWith({
    String? id,
    String? groupId,
    String? name,
    String? frequency,
    Object? weekday = _sentinel,
  }) {
    return Medication(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      name: name ?? this.name,
      frequency: frequency ?? this.frequency,
      weekday: weekday == _sentinel ? this.weekday : weekday as int?,
    );
  }

  static const _sentinel = Object();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'groupId': groupId,
      'name': name,
      'frequency': frequency,
      'weekday': weekday,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory Medication.fromMap(Map<String, dynamic> map, String id) {
    return Medication(
      id: id,
      groupId: map['groupId'] as String,
      name: map['name'] as String,
      frequency: map['frequency'] as String? ?? 'daily',
      weekday: (map['weekday'] as num?)?.toInt(),
    );
  }
}
