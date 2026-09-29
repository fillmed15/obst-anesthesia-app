import '../models/models.dart';

abstract final class SpinalClinicalData {
  static const profiles = <SpinalDrugProfile>[
    SpinalDrugProfile(
      id: 'hyperbaric-bupivacaine',
      label: 'Bupivacaína hiperbárica',
      defaultConcentrationMgMl: 5,
      studiedMinMg: 6,
      studiedMaxMg: 12.5,
      latency: TimeEstimate(
        label: 'Nível sensitivo cirúrgico',
        minMinutes: 4,
        maxMinutes: 10,
        endpoint: 'T4–T6, conforme método do estudo',
      ),
      surgicalDuration: TimeEstimate(
        label: 'Anestesia cirúrgica',
        minMinutes: 60,
        maxMinutes: 110,
        endpoint: 'sem suplementação; grande variabilidade',
      ),
      sensoryRegression: TimeEstimate(
        label: 'Regressão sensitiva',
        minMinutes: 90,
        maxMinutes: 140,
        endpoint: 'recuperação/regressão nos estudos de 8–10 mg + opioide',
      ),
      motorRegression: TimeEstimate(
        label: 'Regressão motora',
        minMinutes: 90,
        maxMinutes: 140,
        endpoint: 'recuperação motora completa aproximada',
      ),
      referenceIds: [
        'arzola-low-dose-2011',
        'sng-baricity-2016',
        'onishi-bupivacaine-2017',
        'alimian-bupivacaine-2017',
      ],
      evidenceContext: 'Cesárea eletiva, principalmente gestantes a termo e com opioide intratecal.',
    ),
    SpinalDrugProfile(
      id: 'isobaric-bupivacaine',
      label: 'Bupivacaína isobárica',
      defaultConcentrationMgMl: 5,
      studiedMinMg: 5,
      studiedMaxMg: 13,
      latency: TimeEstimate(
        label: 'Nível sensitivo cirúrgico',
        minMinutes: 5,
        maxMinutes: 12,
        endpoint: 'T4–T6; em média mais lento que solução hiperbárica',
      ),
      surgicalDuration: TimeEstimate(
        label: 'Anestesia cirúrgica',
        minMinutes: 60,
        maxMinutes: 120,
        endpoint: 'faixa populacional; não garante sucesso individual',
      ),
      sensoryRegression: TimeEstimate(
        label: 'Regressão sensitiva',
        minMinutes: 110,
        maxMinutes: 180,
        endpoint: 'faixa aproximada entre estudos',
      ),
      motorRegression: TimeEstimate(
        label: 'Regressão motora',
        minMinutes: 100,
        maxMinutes: 170,
        endpoint: 'faixa aproximada entre estudos',
      ),
      referenceIds: ['carvalho-isobaric-2005', 'sng-baricity-2016'],
      evidenceContext: 'Cesárea eletiva; estudo dose-resposta associado a fentanil 10 mcg e morfina 200 mcg.',
    ),
    SpinalDrugProfile(
      id: 'isobaric-ropivacaine',
      label: 'Ropivacaína isobárica',
      defaultConcentrationMgMl: 5,
      studiedMinMg: 10,
      studiedMaxMg: 25,
      latency: TimeEstimate(
        label: 'Nível sensitivo cirúrgico',
        minMinutes: 5,
        maxMinutes: 12,
        endpoint: 'dependente de dose e adjuvante',
      ),
      surgicalDuration: TimeEstimate(
        label: 'Anestesia cirúrgica',
        minMinutes: 45,
        maxMinutes: 90,
        endpoint: 'menor potência e duração que bupivacaína',
      ),
      sensoryRegression: TimeEstimate(
        label: 'Regressão sensitiva',
        minMinutes: 75,
        maxMinutes: 120,
        endpoint: 'inclui estudo de 10 mg + fentanil 25 mcg',
      ),
      motorRegression: TimeEstimate(
        label: 'Regressão motora',
        minMinutes: 60,
        maxMinutes: 100,
        endpoint: 'recuperação geralmente mais precoce',
      ),
      referenceIds: ['khaw-ropivacaine-2001', 'sharma-levo-ropi-2025'],
      evidenceContext: 'Evidência heterogênea: ropivacaína simples 10–25 mg e estudo recente com 10 mg + fentanil.',
    ),
    SpinalDrugProfile(
      id: 'isobaric-levobupivacaine',
      label: 'Levobupivacaína isobárica',
      defaultConcentrationMgMl: 5,
      studiedMinMg: 7,
      studiedMaxMg: 10,
      latency: TimeEstimate(
        label: 'Nível sensitivo cirúrgico',
        minMinutes: 4,
        maxMinutes: 10,
        endpoint: 'faixa aproximada; endpoints variam entre T8 e T4',
      ),
      surgicalDuration: TimeEstimate(
        label: 'Anestesia cirúrgica',
        minMinutes: 60,
        maxMinutes: 120,
        endpoint: 'principalmente em associação a fentanil',
      ),
      sensoryRegression: TimeEstimate(
        label: 'Regressão sensitiva',
        minMinutes: 130,
        maxMinutes: 180,
        endpoint: 'dois segmentos/recuperação conforme estudo',
      ),
      motorRegression: TimeEstimate(
        label: 'Regressão motora',
        minMinutes: 110,
        maxMinutes: 160,
        endpoint: 'recuperação motora completa aproximada',
      ),
      referenceIds: ['bidikar-levo-fentanyl-2017', 'sharma-levo-ropi-2025'],
      evidenceContext: 'Cesárea eletiva; estudos de 7–10 mg, frequentemente com fentanil 12,5–25 mcg.',
    ),
  ];

  static SpinalDrugProfile byId(String id) =>
      profiles.firstWhere((profile) => profile.id == id);
}
