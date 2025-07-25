import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

@immutable
class ShoppingItem {
  final String id;
  final String name;
  final bool isBought;
  final String groupId;

  const ShoppingItem({
    required this.id,
    required this.name,
    this.isBought = false,
    required this.groupId,
  });

  ShoppingItem copyWith({
    String? id,
    String? name,
    bool? isBought,
    String? groupId,
  }) {
    return ShoppingItem(
      id: id ?? this.id,
      name: name ?? this.name,
      isBought: isBought ?? this.isBought,
      groupId: groupId ?? this.groupId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'isBought': isBought,
      'groupId': groupId,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory ShoppingItem.fromMap(Map<String, dynamic> map, String id) {
    return ShoppingItem(
      id: id,
      name: map['name'] as String,
      isBought: map['isBought'] as bool? ?? false,
      groupId: map['groupId'] as String,
    );
  }

  @override
  String toString() {
    return 'ShoppingItem(id: $id, name: $name, isBought: $isBought, groupId: $groupId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ShoppingItem &&
        other.id == id &&
        other.name == name &&
        other.isBought == isBought &&
        other.groupId == groupId;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode ^ isBought.hashCode ^ groupId.hashCode;
  }
}
