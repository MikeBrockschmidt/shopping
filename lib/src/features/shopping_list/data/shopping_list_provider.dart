import 'package:flutter/foundation.dart';
import 'package:shopping/src/data/database_repository.dart';
import 'package:shopping/src/features/shopping_list/data/shopping_item.dart';
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
      _items = await _databaseRepository.getShoppingItemsStream(_groupId).first;
    } catch (e) {
      _setErrorMessage('Fehler beim Laden der Einkaufsliste: ${e.toString()}');
      _items = [];
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addItem(String name) async {
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
      );

      await _databaseRepository.createShoppingItem(_groupId, newItem);
      _items.add(newItem);
    } catch (e) {
      _setErrorMessage('Fehler beim Hinzufügen des Artikels: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> removeItem(ShoppingItem item) async {
    _setLoading(true);
    _setErrorMessage(null);

    try {
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

  Future<void> clearCollectedItems() async {
    _setLoading(true);
    _setErrorMessage(null);

    try {
      final List<ShoppingItem> itemsToClear = _items
          .where((item) => item.isBought)
          .toList();
      for (var item in itemsToClear) {
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
