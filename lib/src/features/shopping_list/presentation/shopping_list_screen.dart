import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:drei/src/features/shopping_list/data/shopping_list_provider.dart';
import 'package:drei/src/features/shopping_list/data/shopping_icons.dart';
import 'package:drei/src/features/shopping_list/presentation/collected_items_screen.dart';
import 'package:drei/src/features/shopping_list/presentation/widgets/add_item_dialog.dart';

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

    final Brightness brightness = Theme.of(context).brightness;
    final bool isDarkMode = brightness == Brightness.dark;

    final String backgroundImage = isDarkMode
        ? 'assets/images/wedoshopping_sh-d.png'
        : 'assets/images/wedoshopping_sh.png';

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Add Item Button
              Card(
                child: InkWell(
                  onTap: () async {
                    await showDialog(
                      context: context,
                      builder: (context) => AddItemDialog(
                        groupId: widget.groupId,
                        onAddItem: (name, iconName, imageUrl, hasCustomImage, price) {
                          shoppingListProvider.addItem(
                            name,
                            iconName: iconName,
                            imageUrl: imageUrl,
                            hasCustomImage: hasCustomImage,
                            price: price,
                          );
                        },
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.add_circle_outline,
                          color: Theme.of(context).primaryColor,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Neuen Artikel hinzufügen',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
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
                            padding: const EdgeInsets.all(6.0),
                            child: Row(
                              children: [
                                // Thumbnail Icon oder Image
                                Container(
                                  width: 49,
                                  height: 49,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor.withOpacity(0.1),
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
                                                        color: Theme.of(context).primaryColor,
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
                                                        color: Theme.of(context).primaryColor,
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
                                            color: Theme.of(context).primaryColor,
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
                                        style: TextStyle(
                                          decoration: item.isBought
                                              ? TextDecoration.lineThrough
                                              : null,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item.price != null 
                                            ? '€ ${item.price!.toStringAsFixed(2)}'
                                            : '€ --.--',
                                        style: TextStyle(
                                          decoration: item.isBought
                                              ? TextDecoration.lineThrough
                                              : null,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                    ],
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
                  final collectedItems = shoppingListProvider.items
                      .where((item) => item.isBought)
                      .toList();
                  
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CollectedItems(
                        collectedItems: collectedItems,
                        groupId: widget.groupId,
                        onRemoveItem: (item) {
                          shoppingListProvider.removeItem(item);
                        },
                        onUpdateItem: (updatedItem) {
                          shoppingListProvider.updateItem(updatedItem);
                        },
                      ),
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
