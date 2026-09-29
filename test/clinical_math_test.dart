import 'package:flutter_test/flutter_test.dart';
import 'package:obst_anesthesia_app/calculations/clinical_math.dart';
import 'package:obst_anesthesia_app/calculations/spinal_estimator.dart';
import 'package:obst_anesthesia_app/models/models.dart';

void main() {
  group('Cálculos determinísticos', () {
    test('IMC', () {
      expect(ClinicalMath.bmi(weightKg: 80, heightCm: 160), closeTo(31.25, 0.001));
    });

    test('concentração e volume geram dose', () {
      expect(ClinicalMath.doseFromVolume(concentration: 5, volumeMl: 2), 10);
      expect(ClinicalMath.volumeFromDose(dose: 10, concentration: 5), 2);
    });

    test('PIEB calcula bolus e média horária', () {
      final result = ClinicalMath.pieb(volumeMl: 10, intervalMinutes: 40, localMgMl: 0.625, opioidMcgMl: 2);
      expect(result.localMgPerBolus, 6.25);
      expect(result.opioidMcgPerBolus, 20);
      expect(result.averageMlPerHour, 15);
      expect(result.averageLocalMgPerHour, 9.375);
    });

    test('PCEA separa máximo teórico de administração real', () {
      final result = ClinicalMath.pcea(demandVolumeMl: 5, lockoutMinutes: 15, localMgMl: 1, opioidMcgMl: 2);
      expect(result.maxDemandsPerHour, 4);
      expect(result.maximumMlPerHour, 20);
      expect(result.maximumLocalMgPerHour, 20);
      expect(result.maximumOpioidMcgPerHour, 40);
    });

    test('linha do tempo respeita faixa informada', () {
      final time = DateTime(2026, 9, 28, 14, 10);
      final record = BolusRecord(
        id: '1', administeredAt: time, indication: 'Bolus inicial', method: 'Manual', drug: 'Bupivacaína',
        concentrationMgMl: 1, volumeMl: 10, opioidMcgMl: 2, expectedMinMinutes: 50, expectedMaxMinutes: 90,
      );
      expect(record.localAnestheticMg, 10);
      expect(record.opioidMcg, 20);
      expect(record.reassessAt, DateTime(2026, 9, 28, 15, 0));
      expect(record.windowEnd, DateTime(2026, 9, 28, 15, 40));
    });
  });

  group('Interpretação da raquianestesia', () {
    test('calcula volume e reconhece faixa estudada', () {
      final result = SpinalEstimator.calculate(
        drugId: 'hyperbaric-bupivacaine',
        concentrationMgMl: 5,
        doseMg: 10,
      );

      expect(result.volumeMl, 2);
      expect(result.dosePosition, DosePosition.withinStudied);
      expect(result.profile.latency.minMinutes, 4);
      expect(result.profile.latency.maxMinutes, 10);
    });

    test('baixa dose gera alerta sem alterar cálculo matemático', () {
      final result = SpinalEstimator.calculate(
        drugId: 'hyperbaric-bupivacaine',
        concentrationMgMl: 5,
        doseMg: 6,
      );

      expect(result.volumeMl, 1.2);
      expect(result.alerts.any((item) => item.contains('≤8 mg')), isTrue);
    });

    test('interpreta adjuvantes por faixas revisadas', () {
      final result = SpinalEstimator.calculate(
        drugId: 'hyperbaric-bupivacaine',
        concentrationMgMl: 5,
        doseMg: 10,
        fentanylMcg: 15,
        morphineMcg: 100,
      );

      expect(result.adjuvants, hasLength(2));
      expect(result.adjuvants.first.warning, isNull);
      expect(result.adjuvants.last.summary, contains('PROSPECT'));
    });

    test('dose fora da evidência não extrapola silenciosamente', () {
      final result = SpinalEstimator.calculate(
        drugId: 'isobaric-levobupivacaine',
        concentrationMgMl: 5,
        doseMg: 12,
      );

      expect(result.dosePosition, DosePosition.aboveStudied);
      expect(result.alerts, isNotEmpty);
    });
  });
}
