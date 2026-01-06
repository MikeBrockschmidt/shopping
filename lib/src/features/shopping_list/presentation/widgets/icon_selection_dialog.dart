import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:drei/src/features/shopping_list/data/shopping_icons.dart';
import 'package:drei/src/services/image_service.dart';

class IconImageSelection {
  final bool isCustomImage;
  final String? iconName;
  final String? imageUrl;
  final File? imageFile;
  
  const IconImageSelection.icon(this.iconName) 
    : isCustomImage = false, imageUrl = null, imageFile = null;
  
  const IconImageSelection.image({this.imageUrl, this.imageFile})
    : isCustomImage = true, iconName = null;
}

class IconSelectionDialog extends StatefulWidget {
  final String? currentIconName;
  final String? currentImageUrl;
  final bool? hasCustomImage;
  final String groupId;
  
  const IconSelectionDialog({
    super.key,
    this.currentIconName,
    this.currentImageUrl,
    this.hasCustomImage,
    required this.groupId,
  });

  @override
  State<IconSelectionDialog> createState() => _IconSelectionDialogState();
}

class _IconSelectionDialogState extends State<IconSelectionDialog> with TickerProviderStateMixin {
  late TabController _tabController;
  String? selectedIcon;
  File? selectedImageFile;
  String? selectedImageUrl;
  bool isUploadingImage = false;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Initialize with current values
    if (widget.hasCustomImage == true && widget.currentImageUrl != null) {
      selectedImageUrl = widget.currentImageUrl;
      _tabController.index = 1; // Switch to image tab
    } else {
      selectedIcon = widget.currentIconName ?? 'shopping_cart';
      _tabController.index = 0; // Default to icon tab
    }
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        setState(() {
          selectedImageFile = File(pickedFile.path);
          selectedImageUrl = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Auswählen des Bildes: $e')),
        );
      }
    }
  }
  
  Future<void> _uploadAndReturnImage() async {
    if (selectedImageFile == null) {
      Navigator.of(context).pop(IconImageSelection.image(imageUrl: selectedImageUrl));
      return;
    }
    
    setState(() {
      isUploadingImage = true;
    });
    
    try {
      final imageUrl = await ImageService.uploadItemImage(selectedImageFile!, widget.groupId);
      Navigator.of(context).pop(IconImageSelection.image(imageUrl: imageUrl));
    } catch (e) {
      setState(() {
        isUploadingImage = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler beim Hochladen: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ShoppingIcons.getIconCategories();
    
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.95,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Icon oder Bild auswählen',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Tab Bar
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(icon: Icon(Icons.apps), text: 'Icons'),
                Tab(icon: Icon(Icons.image), text: 'Bilder'),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Icons Tab
                  Column(
                    children: [
                      // Vorschau des ausgewählten Icons
                      if (selectedIcon != null) 
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                ShoppingIcons.getIcon(selectedIcon!),
                                size: 32,
                                color: Theme.of(context).primaryColor,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Ausgewähltes Icon',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                        ),
                      
                      const SizedBox(height: 16),
                      
                      // Icon-Kategorien
                      Expanded(
                        child: DefaultTabController(
                          length: categories.length,
                          child: Column(
                            children: [
                              TabBar(
                                isScrollable: true,
                                tabs: categories
                                    .map((category) => Tab(text: category.name))
                                    .toList(),
                              ),
                              const SizedBox(height: 16),
                              Expanded(
                                child: TabBarView(
                                  children: categories.map((category) {
                                    return GridView.builder(
                                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 4,
                                        mainAxisSpacing: 12,
                                        crossAxisSpacing: 12,
                                      ),
                                      itemCount: category.icons.length,
                                      itemBuilder: (context, index) {
                                        final iconName = category.icons[index];
                                        final isSelected = selectedIcon == iconName;
                                        
                                        return GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              selectedIcon = iconName;
                                              selectedImageFile = null;
                                              selectedImageUrl = null;
                                            });
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: isSelected 
                                                  ? Theme.of(context).primaryColor.withOpacity(0.1)
                                                  : null,
                                              border: Border.all(
                                                color: isSelected 
                                                    ? Theme.of(context).primaryColor
                                                    : Colors.grey.shade300,
                                                width: isSelected ? 2 : 1,
                                              ),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Icon(
                                              ShoppingIcons.getIcon(iconName),
                                              size: 32,
                                              color: isSelected 
                                                  ? Theme.of(context).primaryColor
                                                  : Colors.grey.shade700,
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  // Images Tab
                  Column(
                    children: [
                      // Image Upload Button
                      Card(
                        child: InkWell(
                          onTap: _pickImage,
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.add_a_photo,
                                  size: 48,
                                  color: Theme.of(context).primaryColor,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Bild aus Galerie auswählen',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Das Bild wird automatisch auf 200x200 Pixel skaliert',
                                  style: Theme.of(context).textTheme.bodySmall,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Image Preview
                      if (selectedImageFile != null || selectedImageUrl != null)
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: selectedImageFile != null
                                  ? Image.file(
                                      selectedImageFile!,
                                      fit: BoxFit.contain,
                                    )
                                  : selectedImageUrl != null
                                      ? Image.network(
                                          selectedImageUrl!,
                                          fit: BoxFit.contain,
                                          loadingBuilder: (context, child, loadingProgress) {
                                            if (loadingProgress == null) return child;
                                            return const Center(child: CircularProgressIndicator());
                                          },
                                          errorBuilder: (context, error, stackTrace) {
                                            return const Center(
                                              child: Text('Bild konnte nicht geladen werden'),
                                            );
                                          },
                                        )
                                      : const SizedBox(),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: isUploadingImage ? null : () => Navigator.of(context).pop(),
                  child: const Text('Abbrechen'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: isUploadingImage 
                      ? null
                      : () {
                          if (_tabController.index == 0) {
                            // Icon selected
                            Navigator.of(context).pop(IconImageSelection.icon(selectedIcon));
                          } else {
                            // Image selected
                            _uploadAndReturnImage();
                          }
                        },
                  child: isUploadingImage 
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Auswählen'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}