import 'package:flutter/material.dart';
import 'package:shopping/src/features/shopping_list/data/shopping_item.dart';
import 'package:shopping/src/features/shopping_list/data/shopping_icons.dart';

class CollectedItems extends StatelessWidget {
  final List<ShoppingItem> collectedItems;
  final Function(ShoppingItem) onToggleItem;
  final Function(ShoppingItem) onRemoveItem;

  const CollectedItems({
    super.key,
    required this.collectedItems,
    required this.onToggleItem,
    required this.onRemoveItem,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gekaufte Artikel')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              collectedItems.isEmpty
                  ? const Center(
                      child: SizedBox(
                        height: 200,
                        child: Text('Keine Artikel als "gekauft" markiert.'),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: collectedItems.length,
                      itemBuilder: (context, index) {
                        final item = collectedItems[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                // Thumbnail Icon oder Image
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: item.hasCustomImage && item.imageUrl != null
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.network(
                                            item.imageUrl!,
                                            fit: BoxFit.cover,
                                            width: 40,
                                            height: 40,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Padding(
                                                padding: const EdgeInsets.all(8),
                                                child: Icon(
                                                  Icons.image_not_supported,
                                                  color: Colors.green,
                                                  size: 24,
                                                ),
                                              );
                                            },
                                          ),
                                        )
                                      : Padding(
                                          padding: const EdgeInsets.all(8),
                                          child: Icon(
                                            ShoppingIcons.getIcon(item.iconName ?? 'shopping_cart'),
                                            color: Colors.green,
                                            size: 24,
                                          ),
                                        ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    item.name,
                                    style: TextStyle(
                                      decoration: item.isBought
                                          ? TextDecoration.lineThrough
                                          : null,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.green.shade700,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        item.isBought
                                            ? Icons.check_box
                                            : Icons.check_box_outline_blank,
                                        color: item.isBought
                                            ? Colors.green
                                            : Colors.grey,
                                        size: 28,
                                      ),
                                      onPressed: () {
                                        onToggleItem(item);
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: Colors.redAccent,
                                      ),
                                      onPressed: () {
                                        onRemoveItem(item);
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Zurück"),
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
