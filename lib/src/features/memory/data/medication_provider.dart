import 'dart:async';
import 'package:flutter/material.dart';
import 'package:drei/src/data/database_repository.dart';
import 'package:drei/src/features/memory/domain/medication.dart';

class MedicationProvider with ChangeNotifier {
  final DatabaseRepository _db;
  final String _groupId;

  List<Medication> _medications = [];
  bool _isLoading = false;
  String? _errorMessage;

  StreamSubscription<List<Medication>>? _sub;

  MedicationProvider(this._db, this._groupId) {
    _subscribe();
  }

  List<Medication> get medications => _medications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void clearErrorMessage() {
    _errorMessage = null;
    notifyListeners();
  }

  void _subscribe() {
    _isLoading = true;
    notifyListeners();
    _sub = _db.getMedicationsStream(_groupId).listen((items) {
      _medications = items;
      _isLoading = false;
      notifyListeners();
    }, onError: (e) {
      _errorMessage = 'Fehler beim Laden der Medikamente: $e';
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> addMedication({
    required String name,
    required String frequency,
    int? weekday,
  }) async {
    try {
      await _db.createMedication(
        _groupId,
        Medication(
          id: 'new',
          groupId: _groupId,
          name: name,
          frequency: frequency,
          weekday: weekday,
        ),
      );
    } catch (e) {
      _errorMessage = 'Fehler beim Hinzufügen: $e';
      notifyListeners();
    }
  }

  Future<void> updateMedication({
    required String id,
    required String name,
    required String frequency,
    int? weekday,
  }) async {
    try {
      await _db.updateMedication(
        _groupId,
        id,
        name: name,
        frequency: frequency,
        weekday: weekday,
      );
    } catch (e) {
      _errorMessage = 'Fehler beim Aktualisieren: $e';
      notifyListeners();
    }
  }

  Future<void> deleteMedication(String id) async {
    try {
      await _db.deleteMedication(_groupId, id);
    } catch (e) {
      _errorMessage = 'Fehler beim Löschen: $e';
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
