import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:drei/src/services/image_service.dart';

// Asset logos
const List<String> _assetLogos = [
  'assets/logos/Action.jpg',
  'assets/logos/Aldinord.png',
  'assets/logos/Amazon.jpg',
  'assets/logos/dm.jpg',
  'assets/logos/EDEKA Kuhlmann.jpg',
  'assets/logos/EDEKA Kutsche.jpg',
  'assets/logos/EDEKA-Schinkel.jpg',
  'assets/logos/Edeka-Kallmeyer.jpg',
  'assets/logos/expert-benning.jpg',
  'assets/logos/Kaufland.jpg',
  'assets/logos/Lidl.png',
  'assets/logos/Mueller.jpg',
  'assets/logos/Netto.jpg',
  'assets/logos/Penny.jpg',
  'assets/logos/Rossmann.jpg',
  'assets/logos/GetraenkeHoffmann.jpg',
  'assets/logos/trinkgut.jpg',
  'assets/logos/ThomasPhillips.jpg',
  'assets/logos/toom.jpg',
];

class AddItemDialog extends StatefulWidget {
  final Function(String name, String? iconName, String? imageUrl, bool hasCustomImage, double? price)
      onAddItem;
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
  final TextEditingController _priceController = TextEditingController();
  String? selectedIcon = 'shopping_cart';
  String? selectedImageUrl;
  bool hasCustomImage = false;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _selectImageOnly() async {
    final picker = ImagePicker();
    try {
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (picked == null) return;

      final file = File(picked.path);
      final url = await ImageService.uploadItemImage(file, widget.groupId);

      if (!mounted) return;
      setState(() {
        selectedImageUrl = url;
        selectedIcon = null;
        hasCustomImage = true;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fehler beim Auswählen/Hochladen: \$e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _selectAssetLogo(String assetPath) {
    setState(() {
      selectedImageUrl = assetPath;
      selectedIcon = null;
      hasCustomImage = true;
    });
  }

  bool _isAssetImage(String? imageUrl) {
    return imageUrl?.startsWith('assets/') ?? false;
  }

  Widget _buildImageWidget(String imageUrl, {double width = 32, double height = 32}) {
    if (_isAssetImage(imageUrl)) {
      return Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.image_not_supported,
            size: 32,
            color: Colors.grey.shade600,
          );
        },
      );
    } else {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.image_not_supported,
            size: 32,
            color: Colors.grey.shade600,
          );
        },
      );
    }
  }

  void _addItem() {
    final name = _nameController.text.trim();
    if (name.isNotEmpty) {
      double? price;
      if (_priceController.text.trim().isNotEmpty) {
        // Replace comma with dot for German input (e.g., "2,99" -> "2.99")
        final priceText = _priceController.text.trim().replaceAll(',', '.');
        price = double.tryParse(priceText);
      }
      widget.onAddItem(name, selectedIcon, selectedImageUrl, hasCustomImage, price);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Neuen Artikel hinzufügen',
                style: Theme.of(context).textTheme.titleLarge,
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
              const SizedBox(height: 16),

              // Preis
              TextField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Preis (optional)',
                  border: OutlineInputBorder(),
                  hintText: 'z.B. 2,99',
                  prefixText: '€ ',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 20),

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
              const SizedBox(height: 20),

              // Lokale Logos Galerie
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1,
                ),
                itemCount: _assetLogos.length,
                itemBuilder: (context, index) {
                  final logoPath = _assetLogos[index];
                  final isSelected = selectedImageUrl == logoPath;

                  return InkWell(
                    onTap: () => _selectAssetLogo(logoPath),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : Colors.grey.shade300,
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        color: isSelected
                            ? Theme.of(context).primaryColor.withAlpha(30)
                            : Colors.transparent,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.asset(
                          logoPath,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Icon(
                                Icons.image_not_supported,
                                color: Colors.grey.shade400,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // Bild auswählen
              InkWell(
                onTap: _selectImageOnly,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 32,
                        height: 32,
                        child: selectedImageUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: _buildImageWidget(selectedImageUrl!),
                              )
                            : Icon(
                                Icons.image,
                                size: 32,
                                color: Colors.grey.shade700,
                              ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bild auswählen',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              'Galerie öffnen',
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
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
