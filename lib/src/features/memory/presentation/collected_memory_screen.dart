import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping/src/features/memory/presentation/memory_provider.dart';

class CollectedMemoryScreen extends StatelessWidget {
  final String groupId;

  const CollectedMemoryScreen({super.key, required this.groupId});

  @override
  Widget build(BuildContext context) {
    final memoryProvider = context.watch<MemoryProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Archivierte Memories')),
      body: memoryProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : memoryProvider.memories.where((memory) => memory.isArchived).isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text('Keine archivierten Memories vorhanden.'),
              ),
            )
          : ListView.builder(
              itemCount: memoryProvider.memories
                  .where((memory) => memory.isArchived)
                  .length,
              itemBuilder: (context, index) {
                final memory = memoryProvider.memories
                    .where((memory) => memory.isArchived)
                    .toList()[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListTile(
                      title: Text(
                        memory.name,
                        style: const TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.undo, color: Colors.blueAccent),
                        onPressed: () {
                          memoryProvider.toggleMemoryArchived(memory);
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
