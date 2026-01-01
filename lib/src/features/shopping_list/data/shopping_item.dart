import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

@immutable
class ShoppingItem {
  final String id;
  final String name;
  final bool isBought;
  final String groupId;
  final String? iconName; // Icon name für Material Icons (nullable wenn custom image verwendet wird)
  final String? imageUrl; // URL für custom Bilder aus Firebase Storage
  final bool hasCustomImage; // Flag ob custom Image verwendet wird

  const ShoppingItem({
    required this.id,
    required this.name,
    this.isBought = false,
    required this.groupId,
    this.iconName, // Kann null sein bei custom images
    this.imageUrl,
    this.hasCustomImage = false,
  });

  ShoppingItem copyWith({
    String? id,
    String? name,
    bool? isBought,
    String? groupId,
    Object? iconName = _sentinel, // Use sentinel to detect if iconName was explicitly passed
    Object? imageUrl = _sentinel,
    bool? hasCustomImage,
  }) {
    return ShoppingItem(
      id: id ?? this.id,
      name: name ?? this.name,
      isBought: isBought ?? this.isBought,
      groupId: groupId ?? this.groupId,
      iconName: iconName == _sentinel ? this.iconName : iconName as String?,
      imageUrl: imageUrl == _sentinel ? this.imageUrl : imageUrl as String?,
      hasCustomImage: hasCustomImage ?? this.hasCustomImage,
    );
  }

  static const _sentinel = Object();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'isBought': isBought,
      'groupId': groupId,
      'iconName': iconName,
      'imageUrl': imageUrl,
      'hasCustomImage': hasCustomImage,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory ShoppingItem.fromMap(Map<String, dynamic> map, String id) {
    final hasCustomImage = map['hasCustomImage'] as bool? ?? false;
    return ShoppingItem(
      id: id,
      name: map['name'] as String,
      isBought: map['isBought'] as bool? ?? false,
      groupId: map['groupId'] as String,
      iconName: hasCustomImage ? map['iconName'] as String? : (map['iconName'] as String? ?? 'shopping_cart'),
      imageUrl: map['imageUrl'] as String?,
      hasCustomImage: hasCustomImage,
    );
  }

  @override
  String toString() {
    return 'ShoppingItem(id: $id, name: $name, isBought: $isBought, groupId: $groupId, iconName: $iconName, imageUrl: $imageUrl, hasCustomImage: $hasCustomImage)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ShoppingItem &&
        other.id == id &&
        other.name == name &&
        other.isBought == isBought &&
        other.groupId == groupId &&
        other.iconName == iconName &&
        other.imageUrl == imageUrl &&
        other.hasCustomImage == hasCustomImage;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode ^ isBought.hashCode ^ groupId.hashCode ^ iconName.hashCode ^ imageUrl.hashCode ^ hasCustomImage.hashCode;
  }
}
