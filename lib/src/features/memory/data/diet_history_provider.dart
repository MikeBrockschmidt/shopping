import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'diet_history_model.dart';

class DietHistoryProvider extends ChangeNotifier {
  final String groupId;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<DietHistory> _dietHistory = [];
  bool _isLoading = false;
  String? _errorMessage;

  DietHistoryProvider({required this.groupId});

  List<DietHistory> get dietHistory => _dietHistory;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> saveDietStatus(int status, {DateTime? date, List<String>? triggers, String? notes}) async {
    try {
      _isLoading = true;
      notifyListeners();

      final targetDate = date ?? DateTime.now();
      final dateKey = '${targetDate.year}-${targetDate.month.toString().padLeft(2, '0')}-${targetDate.day.toString().padLeft(2, '0')}';
      
      print('DEBUG DietHistoryProvider: dateKey=$dateKey, status=$status');

      final dietHistory = DietHistory(
        id: const Uuid().v4(),
        groupId: groupId,
        date: targetDate,
        status: status,
        createdAt: DateTime.now(),
        triggers: triggers ?? const <String>[],
        notes: notes ?? '',
      );

      print('DEBUG DietHistoryProvider: Creating map with status=$status');
      final map = dietHistory.toMap();
      print('DEBUG DietHistoryProvider: Map=$map');
      print('DEBUG DietHistoryProvider: Saving to groups/$groupId/memory/$dateKey');

      await _firestore
          .collection('groups')
          .doc(groupId)
          .collection('memory')
          .doc(dateKey)
          .set(map, SetOptions(merge: true));
      
      print('DEBUG DietHistoryProvider: Successfully saved diet status');

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Fehler beim Speichern: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchDietHistory({int days = 90}) async {
    try {
      _isLoading = true;
      notifyListeners();

      final startDate = DateTime.now().subtract(Duration(days: days));

      // Lade alle Daten und filtere client-seitig
      final snapshot = await _firestore
          .collection('groups')
          .doc(groupId)
          .collection('memory')
          .get();

      _dietHistory = snapshot.docs
          .map((doc) => DietHistory.fromMap(doc.data()))
          .where((history) => history.date.isAfter(startDate) || history.date.day == startDate.day && history.date.month == startDate.month && history.date.year == startDate.year)
          .toList();

      // Sortiere nach Datum absteigend
      _dietHistory.sort((a, b) => b.date.compareTo(a.date));

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Fehler beim Laden: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearErrorMessage() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> deleteDietStatus(DateTime date) async {
    try {
      _isLoading = true;
      notifyListeners();

      final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      await _firestore
          .collection('groups')
          .doc(groupId)
          .collection('memory')
          .doc(dateKey)
          .delete();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Fehler beim Löschen: $e';
      _isLoading = false;
      notifyListeners();
    }
  }
}
