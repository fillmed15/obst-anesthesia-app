import '../clinical_data/spinal_clinical_data.dart';
import '../models/models.dart';
import 'clinical_math.dart';

abstract final class SpinalEstimator {
  static SpinalEstimate calculate({
    required String drugId,
    required double concentrationMgMl,
    required double doseMg,
    double fentanylMcg = 0,
    double sufentanilMcg = 0,
    double morphineMcg = 0,
  }) {
    final profile = SpinalClinicalData.byId(drugId);
    final position = doseMg < profile.studiedMinMg
        ? DosePosition.belowStudied
        : doseMg > profile.studiedMaxMg
            ? DosePosition.aboveStudied
            : DosePosition.withinStudied;
    final alerts = <String>[];
    final refs = <String>{...profile.referenceIds};

    if (position == DosePosition.belowStudied) {
      alerts.add(
        'Dose abaixo da principal faixa estudada para este perfil. Não extrapolar os tempos; risco de suplementação pode ser maior.',
      );
    } else if (position == DosePosition.aboveStudied) {
      alerts.add(
        'Dose acima da principal faixa estudada. Os tempos não são extrapolados; considerar maior bloqueio e efeitos hemodinâmicos.',
      );
    }

    if (drugId.contains('bupivacaine') && doseMg <= 8) {
      alerts.add(
        'Bupivacaína ≤8 mg é classificada como baixa dose em meta-análise: menos hipotensão/náusea, porém mais suplementação intraoperatória.',
      );
      refs.add('arzola-low-dose-2011');
    }

    final adjuvants = <AdjuvantInterpretation>[];
    if (fentanylMcg > 0) {
      final within = fentanylMcg >= 10 && fentanylMcg <= 25;
      adjuvants.add(AdjuvantInterpretation(
        name: 'Fentanil',
        doseMcg: fentanylMcg,
        summary: within ? 'Faixa obstétrica estudada' : 'Fora da faixa principal revisada',
        details: 'Reduz suplementação intraoperatória; não altera consistentemente a latência sensitiva nem a duração motora. Em meta-análise, retardou a primeira solicitação analgésica em cerca de 69–113 min.',
        referenceIds: const ['uppal-fentanyl-2020'],
        warning: within ? null : 'A principal literatura revisada concentra-se em aproximadamente 10–25 mcg.',
      ));
      refs.add('uppal-fentanyl-2020');
    }
    if (sufentanilMcg > 0) {
      final within = sufentanilMcg >= 1.5 && sufentanilMcg <= 5;
      adjuvants.add(AdjuvantInterpretation(
        name: 'Sufentanil',
        doseMcg: sufentanilMcg,
        summary: within ? 'Faixa obstétrica estudada' : 'Fora da faixa principal revisada',
        details: 'Opioide lipofílico de início rápido. Doses de 2,5–5 mcg prolongaram analgesia; estudos relatam aproximadamente 3–6 h, com prurido como efeito adverso relevante.',
        referenceIds: const ['dahlgren-opioids-1997', 'wilwerth-opioids-2016'],
        warning: within ? null : 'A principal faixa revisada para cesárea é 1,5–5 mcg.',
      ));
      refs.addAll(['dahlgren-opioids-1997', 'wilwerth-opioids-2016']);
    }
    if (morphineMcg > 0) {
      final recommended = morphineMcg >= 50 && morphineMcg <= 100;
      final higher = morphineMcg > 100 && morphineMcg <= 250;
      adjuvants.add(AdjuvantInterpretation(
        name: 'Morfina',
        doseMcg: morphineMcg,
        summary: recommended
            ? 'Faixa recomendada PROSPECT 2026'
            : higher
                ? 'Dose acima da faixa preferida atual'
                : 'Fora da faixa principal revisada',
        details: 'Analgesia pós-operatória prolongada, geralmente ≈10–24 h. Doses >100 mcg acrescentam em média ~4,5 h até o primeiro resgate, ao custo de mais prurido e vômitos.',
        referenceIds: const ['prospect-cesarean-2026', 'sultan-morphine-2016'],
        warning: recommended ? null : 'Reavaliar benefício, efeitos adversos e protocolo de monitorização respiratória.',
      ));
      refs.addAll(['prospect-cesarean-2026', 'sultan-morphine-2016']);
    }

    return SpinalEstimate(
      profile: profile,
      doseMg: doseMg,
      concentrationMgMl: concentrationMgMl,
      volumeMl: ClinicalMath.volumeFromDose(
        dose: doseMg,
        concentration: concentrationMgMl,
      ),
      dosePosition: position,
      adjuvants: adjuvants,
      alerts: alerts,
      referenceIds: refs.toList(),
    );
  }
}
