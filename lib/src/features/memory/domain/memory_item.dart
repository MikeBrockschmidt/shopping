import 'package:cloud_firestore/cloud_firestore.dart';

class MemoryItem {
  final String id;
  final String name;
  final bool isArchived;

  MemoryItem({required this.id, required this.name, this.isArchived = false});

  factory MemoryItem.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return MemoryItem(
      id: doc.id,
      name: data['name'] ?? '',
      isArchived: data['isArchived'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'isArchived': isArchived,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
