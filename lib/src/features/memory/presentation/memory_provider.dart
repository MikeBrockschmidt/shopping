import 'package:flutter/material.dart';
import 'package:shopping/src/data/database_repository.dart';
import 'package:shopping/src/features/memory/domain/memory_item.dart';

class MemoryProvider with ChangeNotifier {
  final DatabaseRepository _db;
  final String _groupId;
  List<MemoryItem> _memories = [];
  bool _isLoading = false;
  String? _errorMessage;

  MemoryProvider(this._db, this._groupId) {
    fetchMemories();
  }

  List<MemoryItem> get memories => _memories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void clearErrorMessage() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> fetchMemories() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _memories = await _db.getMemories(_groupId);
    } catch (e) {
      _errorMessage = 'Fehler beim Laden der Memories: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addMemory(String name) async {
    if (name.trim().isEmpty) {
      _errorMessage = 'Der Name des Memories darf nicht leer sein.';
      notifyListeners();
      return;
    }
    try {
      await _db.addMemory(
        _groupId,
        name,
      ); // Angenommen, du hast eine addMemory-Methode
      await fetchMemories(); // Nach dem Hinzufügen neu laden
    } catch (e) {
      _errorMessage = 'Fehler beim Hinzufügen des Memories: $e';
      notifyListeners();
    }
  }

  Future<void> toggleMemoryArchived(MemoryItem memory) async {
    try {
      if (memory.isArchived) {
        await _db.unarchiveMemory(
          _groupId,
          memory.id,
        ); // Neue Methode im DB-Repo
      } else {
        await _db.archiveMemory(_groupId, memory.id); // Neue Methode im DB-Repo
      }
      await fetchMemories();
    } catch (e) {
      _errorMessage = 'Fehler beim Aktualisieren des Memories: $e';
      notifyListeners();
    }
  }

  Future<void> removeMemory(MemoryItem memory) async {
    try {
      await _db.removeMemory(
        _groupId,
        memory.id,
      ); // Angenommen, du hast eine removeMemory-Methode
      await fetchMemories();
    } catch (e) {
      _errorMessage = 'Fehler beim Entfernen des Memories: $e';
      notifyListeners();
    }
  }
}
