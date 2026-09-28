import 'package:flutter/material.dart';

enum EvidenceKind { calculation, estimate, guideline, pending }

class EvidenceReference {
  const EvidenceReference({
    required this.id,
    required this.group,
    required this.authors,
    required this.title,
    required this.source,
    required this.year,
    required this.url,
    this.doi,
    this.pmid,
    this.population,
    this.notes,
    required this.lastReviewed,
  });

  final String id;
  final String group;
  final String authors;
  final String title;
  final String source;
  final int year;
  final String url;
  final String? doi;
  final String? pmid;
  final String? population;
  final String? notes;
  final DateTime lastReviewed;
}

class EvidenceMatrixRow {
  const EvidenceMatrixRow({
    required this.variable,
    required this.population,
    required this.medication,
    required this.technique,
    required this.exposure,
    required this.outcome,
    required this.estimate,
    required this.referenceId,
    required this.year,
    required this.notes,
  });

  final String variable;
  final String population;
  final String medication;
  final String technique;
  final String exposure;
  final String outcome;
  final String estimate;
  final String referenceId;
  final int year;
  final String notes;
}

class PatientProfile {
  String? identifier;
  int? ageYears;
  int? gestationalWeeks;
  int? gestationalDays;
  double? weightKg;
  double? heightCm;
  int? parity;
  int? systolicBp;
  int? diastolicBp;
  int? heartRate;
  int? plateletsThousands;
  double? hemoglobin;
  bool anticoagulantUse = false;
  final Set<String> conditions = {};

  double? get bmi {
    if (weightKg == null || heightCm == null || heightCm! <= 0) return null;
    final meters = heightCm! / 100;
    return weightKg! / (meters * meters);
  }

  String get compactSummary {
    final parts = <String>[];
    if (ageYears != null) parts.add('${ageYears}a');
    if (gestationalWeeks != null) parts.add('${gestationalWeeks}+${gestationalDays ?? 0}s');
    if (weightKg != null) parts.add('${_number(weightKg!)} kg');
    if (plateletsThousands != null) parts.add('PLQ ${plateletsThousands}k');
    return parts.isEmpty ? 'Dados opcionais' : parts.join(' • ');
  }

  static String _number(double value) =>
      value == value.roundToDouble() ? value.toStringAsFixed(0) : value.toStringAsFixed(1);
}

class EpiduralCatheter {
  DateTime? installedAt;
  String? punctureLevel;
  double? spaceDepthCm;
  double? catheterThreadedCm;
  double? skinMarkCm;
  String? test;
}

class BolusRecord {
  const BolusRecord({
    required this.id,
    required this.administeredAt,
    required this.indication,
    required this.method,
    required this.drug,
    required this.concentrationMgMl,
    required this.volumeMl,
    required this.opioidMcgMl,
    required this.expectedMinMinutes,
    required this.expectedMaxMinutes,
  });

  final String id;
  final DateTime administeredAt;
  final String indication;
  final String method;
  final String drug;
  final double concentrationMgMl;
  final double volumeMl;
  final double opioidMcgMl;
  final int expectedMinMinutes;
  final int expectedMaxMinutes;

  double get localAnestheticMg => concentrationMgMl * volumeMl;
  double get opioidMcg => opioidMcgMl * volumeMl;
  DateTime get reassessAt => administeredAt.add(Duration(minutes: expectedMinMinutes));
  DateTime get windowEnd => administeredAt.add(Duration(minutes: expectedMaxMinutes));
}

class EmergencyStep {
  const EmergencyStep(this.label, this.items, {this.danger = false});
  final String label;
  final List<String> items;
  final bool danger;
}

class EmergencyProtocol {
  const EmergencyProtocol({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.steps,
    required this.referenceIds,
    this.reviewPending = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final List<EmergencyStep> steps;
  final List<String> referenceIds;
  final bool reviewPending;
}
