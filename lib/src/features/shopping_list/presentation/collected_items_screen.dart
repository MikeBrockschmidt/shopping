import 'package:flutter/material.dart';
import 'package:memory/src/features/shopping_list/data/shopping_item.dart';
import 'package:memory/src/features/shopping_list/data/shopping_icons.dart';
import 'package:memory/src/features/shopping_list/presentation/widgets/edit_item_dialog.dart';

class CollectedItems extends StatelessWidget {
  final List<ShoppingItem> collectedItems;
  final Function(ShoppingItem) onRemoveItem;
  final Function(ShoppingItem) onUpdateItem;
  final String groupId;

  const CollectedItems({
    super.key,
    required this.collectedItems,
    required this.onRemoveItem,
    required this.onUpdateItem,
    required this.groupId,
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
                            padding: const EdgeInsets.all(6.0),
                            child: Row(
                              children: [
                                // Thumbnail Icon oder Image
                                Container(
                                  width: 49,
                                  height: 49,
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: item.hasCustomImage && item.imageUrl != null
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: item.imageUrl!.startsWith('assets/')
                                              ? Image.asset(
                                                  item.imageUrl!,
                                                  fit: BoxFit.cover,
                                                  width: 49,
                                                  height: 49,
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
                                                )
                                              : Image.network(
                                                  item.imageUrl!,
                                                  fit: BoxFit.cover,
                                                  width: 49,
                                                  height: 49,
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
                                                  loadingBuilder: (context, child, loadingProgress) {
                                                    if (loadingProgress == null) return child;
                                                    return Center(
                                                      child: SizedBox(
                                                        width: 16,
                                                        height: 16,
                                                        child: CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                          value: loadingProgress.expectedTotalBytes != null
                                                              ? loadingProgress.cumulativeBytesLoaded / 
                                                                loadingProgress.expectedTotalBytes!
                                                              : null,
                                                        ),
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
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.name,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.green,
                                        ),
                                      ),
                                      if (item.price != null)
                                        Text(
                                          '€ ${item.price!.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit_outlined,
                                        color: Colors.blueAccent,
                                      ),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => EditItemDialog(
                                            item: item,
                                            groupId: groupId,
                                            onSaveItem: (updatedItem) {
                                              onUpdateItem(updatedItem);
                                              Navigator.pop(context); // Dialog schließen
                                            },
                                          ),
                                        );
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
