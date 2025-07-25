// lib/src/features/memory/domain/memory_item.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class MemoryItem {
  final String id;
  final String name;
  final bool isArchived; // Oder isRemembered, je nach Anwendungsfall

  MemoryItem({required this.id, required this.name, this.isArchived = false});

  // Factory-Methode zum Erstellen eines MemoryItem-Objekts aus einem Firestore-Dokument
  factory MemoryItem.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return MemoryItem(
      id: doc.id,
      name: data['name'] ?? '',
      isArchived: data['isArchived'] ?? false,
    );
  }

  // Methode zum Konvertieren eines MemoryItem-Objekts in ein Map für Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'isArchived': isArchived,
      'createdAt':
          FieldValue.serverTimestamp(), // Optional: Erstellungszeitpunkt
    };
  }
}
