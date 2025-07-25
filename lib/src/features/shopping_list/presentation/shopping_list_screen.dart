import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping/src/features/shopping_list/data/shopping_list_provider.dart';
import 'package:shopping/src/features/shopping_list/presentation/collected_items_screen.dart';

class ShoppingListScreen extends StatefulWidget {
  final String groupId;

  const ShoppingListScreen({super.key, required this.groupId});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  static final TextEditingController _itemController = TextEditingController();

  void _shoppingListProviderListener() {
    final shoppingListProvider = context.read<ShoppingListProvider>();
    if (shoppingListProvider.errorMessage != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(shoppingListProvider.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
        shoppingListProvider.clearErrorMessage();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    context.read<ShoppingListProvider>().addListener(
      _shoppingListProviderListener,
    );
  }

  @override
  void dispose() {
    context.read<ShoppingListProvider>().removeListener(
      _shoppingListProviderListener,
    );
    _itemController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shoppingListProvider = context.watch<ShoppingListProvider>();

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _itemController,
                      decoration: const InputDecoration(
                        hintText: 'Neuen Artikel hinzufügen',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (value) {
                        shoppingListProvider.addItem(value);
                        _itemController.clear();
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      shoppingListProvider.addItem(_itemController.text);
                      _itemController.clear();
                    },
                    color: Theme.of(context).primaryColor,
                    iconSize: 30,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              shoppingListProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : shoppingListProvider.items
                        .where((item) => !item.isBought)
                        .isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text('Keine Artikel auf der Einkaufsliste.'),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: shoppingListProvider.items
                          .where((item) => !item.isBought)
                          .length,
                      itemBuilder: (context, index) {
                        final item = shoppingListProvider.items
                            .where((item) => !item.isBought)
                            .toList()[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
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
                                      ),
                                      onPressed: () {
                                        shoppingListProvider.toggleItemBought(
                                          item,
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
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
              const SizedBox(height: 10),
              FilledButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return CollectedItems(groupId: widget.groupId);
                      },
                    ),
                  );
                },
                child: const Text("Gekaufte Artikel anzeigen"),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
