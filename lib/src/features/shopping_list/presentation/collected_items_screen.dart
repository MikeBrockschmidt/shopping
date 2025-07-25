import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping/src/features/shopping_list/data/shopping_list_provider.dart';

class CollectedItems extends StatelessWidget {
  final String groupId;

  const CollectedItems({super.key, required this.groupId});

  @override
  Widget build(BuildContext context) {
    final shoppingListProvider = context.watch<ShoppingListProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Gekaufte Artikel')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              shoppingListProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : shoppingListProvider.items
                        .where((item) => item.isBought == true)
                        .isEmpty
                  ? const Center(
                      child: SizedBox(
                        height: 200,
                        child: Text('Keine Artikel als "gekauft" markiert.'),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: shoppingListProvider.items
                          .where((item) => item.isBought == true)
                          .length,
                      itemBuilder: (context, index) {
                        final item = shoppingListProvider.items
                            .where((item) => item.isBought == true)
                            .toList()[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item.name,
                                    style: TextStyle(
                                      decoration: item.isBought
                                          ? TextDecoration.lineThrough
                                          : null,
                                      fontSize: 18,
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
                                        shoppingListProvider.toggleItemBought(
                                          item,
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: Colors.redAccent,
                                      ),
                                      onPressed: () {
                                        shoppingListProvider.removeItem(item);
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
