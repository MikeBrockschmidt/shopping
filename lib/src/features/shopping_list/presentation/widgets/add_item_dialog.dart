import 'package:flutter/material.dart';
import 'package:shopping/src/features/shopping_list/data/shopping_icons.dart';
import 'package:shopping/src/features/shopping_list/presentation/widgets/icon_selection_dialog.dart';

class AddItemDialog extends StatefulWidget {
  final Function(String name, String? iconName, String? imageUrl, bool hasCustomImage) onAddItem;
  final String groupId;
  
  const AddItemDialog({
    super.key,
    required this.onAddItem,
    required this.groupId,
  });

  @override
  State<AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddItemDialog> {
  final TextEditingController _nameController = TextEditingController();
  String? selectedIcon = 'shopping_cart';
  String? selectedImageUrl;
  bool hasCustomImage = false;
  
  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _selectIconOrImage() async {
    final result = await showDialog<IconImageSelection>(
      context: context,
      builder: (context) => IconSelectionDialog(
        currentIconName: selectedIcon,
        currentImageUrl: selectedImageUrl,
        hasCustomImage: hasCustomImage,
        groupId: widget.groupId,
      ),
    );
    
    if (result != null) {
      setState(() {
        if (result.isCustomImage) {
          selectedImageUrl = result.imageUrl;
          selectedIcon = null;
          hasCustomImage = true;
        } else {
          selectedIcon = result.iconName ?? 'shopping_cart';
          selectedImageUrl = null;
          hasCustomImage = false;
        }
      });
    }
  }
  
  void _addItem() {
    final name = _nameController.text.trim();
    if (name.isNotEmpty) {
      widget.onAddItem(name, selectedIcon, selectedImageUrl, hasCustomImage);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Neuen Artikel hinzufügen',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            
            // Artikel Name
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Artikelname',
                border: OutlineInputBorder(),
                hintText: 'z.B. Milch, Brot, Äpfel...',
              ),
              onSubmitted: (_) => _addItem(),
              autofocus: true,
            ),
            
            const SizedBox(height: 20),
            
            // Icon/Image Auswahl
            InkWell(
              onTap: _selectIconOrImage,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    // Icon oder Image anzeigen
                    SizedBox(
                      width: 32,
                      height: 32,
                      child: hasCustomImage && selectedImageUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.network(
                                selectedImageUrl!,
                                fit: BoxFit.cover,
                                width: 32,
                                height: 32,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.image_not_supported,
                                    size: 32,
                                    color: Colors.grey.shade600,
                                  );
                                },
                              ),
                            )
                          : Icon(
                              ShoppingIcons.getIcon(selectedIcon ?? 'shopping_cart'),
                              size: 32,
                              color: Theme.of(context).primaryColor,
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hasCustomImage ? 'Bild auswählen' : 'Icon auswählen',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            'Tippen um zu ändern',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Abbrechen'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _addItem,
                  child: const Text('Hinzufügen'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}