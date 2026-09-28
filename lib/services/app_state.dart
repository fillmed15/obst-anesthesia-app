import 'package:flutter/material.dart';

import '../models/models.dart';

class AppState extends ChangeNotifier {
  final patient = PatientProfile();
  final catheter = EpiduralCatheter();
  final List<BolusRecord> boluses = [];

  void updatePatient(VoidCallback mutation) {
    mutation();
    notifyListeners();
  }

  void updateCatheter(VoidCallback mutation) {
    mutation();
    notifyListeners();
  }

  void addBolus(BolusRecord record) {
    boluses.add(record);
    boluses.sort((a, b) => a.administeredAt.compareTo(b.administeredAt));
    notifyListeners();
  }
}

class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required super.notifier, required super.child});

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope não encontrado.');
    return scope!.notifier!;
  }
}
