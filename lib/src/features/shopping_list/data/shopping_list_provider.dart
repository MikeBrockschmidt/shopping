import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shopping/src/data/database_repository.dart';
import 'package:shopping/src/features/shopping_list/data/shopping_item.dart';
import 'package:shopping/src/services/image_service.dart';
import 'package:uuid/uuid.dart';

class ShoppingListProvider with ChangeNotifier {
  final DatabaseRepository _databaseRepository;
  final String _groupId;
  List<ShoppingItem> _items = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ShoppingItem> get items => _items;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  ShoppingListProvider(this._databaseRepository, this._groupId) {
    _loadShoppingList();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setErrorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearErrorMessage() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  Future<void> _loadShoppingList() async {
    _setLoading(true);
    _setErrorMessage(null);

    try {
      print('ShoppingListProvider: Loading shopping list for group $_groupId');

      // Stream listening instead of .first to avoid permission errors
      final stream = _databaseRepository.getShoppingItemsStream(_groupId);
      _items = await stream.first;

      print('ShoppingListProvider: Successfully loaded ${_items.length} items');
    } catch (e) {
      print('ShoppingListProvider: Error loading shopping list: $e');
      _setErrorMessage('Fehler beim Laden der Einkaufsliste: ${e.toString()}');
      _items = [];
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addItem(
    String name, {
    String? iconName,
    String? imageUrl,
    bool hasCustomImage = false,
    double? price,
  }) async {
    if (name.trim().isEmpty) {
      _setErrorMessage('Der Artikelname darf nicht leer sein.');
      return;
    }

    _setLoading(true);
    _setErrorMessage(null);

    try {
      final String newItemId = const Uuid().v4();
      final ShoppingItem newItem = ShoppingItem(
        id: newItemId,
        name: name.trim(),
        isBought: false,
        groupId: _groupId,
        iconName: hasCustomImage ? null : (iconName ?? 'shopping_cart'),
        imageUrl: hasCustomImage ? imageUrl : null,
        hasCustomImage: hasCustomImage,
        price: price,
      );

      // Debugging: Ausgabe der Gruppen-ID und Artikel-Daten
      print('Creating shopping item for group: $_groupId');
      print('Item data: ${newItem.toMap()}');

      await _databaseRepository.createShoppingItem(_groupId, newItem);
      _items.add(newItem);

      if (hasCustomImage && imageUrl != null) {
        print('Successfully created shopping item: ${newItem.name} with custom image: $imageUrl');
      } else {
        print('Successfully created shopping item: ${newItem.name} with icon: ${iconName ?? 'shopping_cart'}');
      }
    } catch (e) {
      print('Error creating shopping item: $e');
      _setErrorMessage('Fehler beim Hinzufügen des Artikels: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> removeItem(ShoppingItem item) async {
    _setLoading(true);
    _setErrorMessage(null);

    try {
      // Delete custom image from Firebase Storage if it exists
      if (item.hasCustomImage && item.imageUrl != null) {
        try {
          await ImageService.deleteItemImage(item.imageUrl!);
          print('Successfully deleted custom image for item: ${item.name}');
        } catch (e) {
          print('Warning: Could not delete custom image for item ${item.name}: $e');
          // Continue with item deletion even if image deletion fails
        }
      }
      
      await _databaseRepository.deleteShoppingItem(_groupId, item.id);
      _items.removeWhere((i) => i.id == item.id);
    } catch (e) {
      _setErrorMessage('Fehler beim Entfernen des Artikels: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> toggleItemBought(ShoppingItem item) async {
    _setLoading(true);
    _setErrorMessage(null);

    try {
      final updatedItem = item.copyWith(isBought: !item.isBought);
      await _databaseRepository.updateShoppingItem(
        _groupId,
        updatedItem.id,
        updatedItem.isBought,
      );

      final index = _items.indexWhere((i) => i.id == item.id);
      if (index != -1) {
        _items[index] = updatedItem;
      }
    } catch (e) {
      _setErrorMessage(
        'Fehler beim Aktualisieren des Artikels: ${e.toString()}',
      );
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateItem(ShoppingItem updatedItem) async {
    _setLoading(true);
    _setErrorMessage(null);

    try {
      // Update local state immediately
      final index = _items.indexWhere((i) => i.id == updatedItem.id);
      if (index != -1) {
        _items[index] = updatedItem;
        notifyListeners();
      }

      // Update in Firestore using the existing collection reference
      await FirebaseFirestore.instance
          .collection('groups')
          .doc(_groupId)
          .collection('shopping_items')
          .doc(updatedItem.id)
          .update({
            'price': updatedItem.price,
            'imageUrl': updatedItem.imageUrl,
            'hasCustomImage': updatedItem.hasCustomImage,
          });
    } catch (e) {
      _setErrorMessage('Fehler beim Aktualisieren des Artikels: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> clearCollectedItems() async {
    _setLoading(true);
    _setErrorMessage(null);

    try {
      final List<ShoppingItem> itemsToClear = _items
          .where((item) => item.isBought)
          .toList();
      
      for (var item in itemsToClear) {
        // Delete custom image from Firebase Storage if it exists
        if (item.hasCustomImage && item.imageUrl != null) {
          try {
            await ImageService.deleteItemImage(item.imageUrl!);
            print('Successfully deleted custom image for collected item: ${item.name}');
          } catch (e) {
            print('Warning: Could not delete custom image for collected item ${item.name}: $e');
            // Continue with item deletion even if image deletion fails
          }
        }
        
        await _databaseRepository.deleteShoppingItem(_groupId, item.id);
      }
      _items.removeWhere((item) => item.isBought);
    } catch (e) {
      _setErrorMessage(
        'Fehler beim Löschen der gekauften Artikel: ${e.toString()}',
      );
    } finally {
      _setLoading(false);
    }
  }
}
