import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../calculations/spinal_estimator.dart';
import '../clinical_data/spinal_clinical_data.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class SpinalScreen extends StatefulWidget {
  const SpinalScreen({super.key});

  @override
  State<SpinalScreen> createState() => _SpinalScreenState();
}

class _SpinalScreenState extends State<SpinalScreen> {
  String technique = 'Raquianestesia';
  String drugId = 'hyperbaric-bupivacaine';
  final concentration = TextEditingController(text: '5');
  final dose = TextEditingController();
  final fentanyl = TextEditingController();
  final morphine = TextEditingController();
  final sufentanil = TextEditingController();

  @override
  void dispose() {
    for (final item in [concentration, dose, fentanyl, morphine, sufentanil]) {
      item.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = SpinalClinicalData.byId(drugId);
    final conc = parseNumber(concentration.text);
    final selectedDose = parseNumber(dose.text);
    final estimate = conc != null && conc > 0 && selectedDose != null && selectedDose > 0
        ? SpinalEstimator.calculate(
            drugId: drugId,
            concentrationMgMl: conc,
            doseMg: selectedDose,
            fentanylMcg: parseNumber(fentanyl.text) ?? 0,
            morphineMcg: parseNumber(morphine.text) ?? 0,
            sufentanilMcg: parseNumber(sufentanil.text) ?? 0,
          )
        : null;

    return AppPage(
      title: 'Raquianestesia',
      child: ResponsiveBody(children: [
        ClinicalCard(
          title: 'Prescrição',
          icon: Icons.medication_liquid_outlined,
          child: Column(children: [
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'Raquianestesia', label: Text('Raqui')),
                ButtonSegment(value: 'CSE', label: Text('CSE')),
              ],
              selected: {technique},
              onSelectionChanged: (value) => setState(() => technique = value.first),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: drugId,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Anestésico local'),
              items: SpinalClinicalData.profiles
                  .map((item) => DropdownMenuItem(value: item.id, child: Text(item.label)))
                  .toList(),
              onChanged: (value) {
                final next = SpinalClinicalData.byId(value!);
                setState(() {
                  drugId = value;
                  concentration.text = formatNumber(next.defaultConcentrationMgMl);
                  dose.clear();
                });
              },
            ),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: _numberField(concentration, 'Concentração', 'mg/mL')),
              const SizedBox(width: 10),
              Expanded(child: _numberField(dose, 'Dose prescrita', 'mg')),
            ]),
            const SizedBox(height: 10),
            _StudiedDoseChips(
              profile: profile,
              onSelected: (value) {
                dose.text = formatNumber(value);
                setState(() {});
              },
            ),
          ]),
        ),
        ClinicalCard(
          title: 'Adjuvantes intratecais',
          icon: Icons.add_circle_outline,
          child: Column(children: [
            Row(children: [
              Expanded(child: _numberField(fentanyl, 'Fentanil', 'mcg')),
              const SizedBox(width: 10),
              Expanded(child: _numberField(morphine, 'Morfina', 'mcg')),
            ]),
            const SizedBox(height: 10),
            _numberField(sufentanil, 'Sufentanil', 'mcg'),
            const SizedBox(height: 8),
            Wrap(spacing: 7, runSpacing: 7, children: [
              _quickAdjuvant('Fentanil 15', fentanyl, 15),
              _quickAdjuvant('Morfina 100', morphine, 100),
              _quickAdjuvant('Sufentanil 2,5', sufentanil, 2.5),
              ActionChip(
                avatar: const Icon(Icons.clear, size: 16),
                label: const Text('Limpar'),
                onPressed: () {
                  fentanyl.clear();
                  morphine.clear();
                  sufentanil.clear();
                  setState(() {});
                },
              ),
            ]),
          ]),
        ),
        if (estimate == null)
          ClinicalCard(
            title: 'Resultado',
            icon: Icons.insights_outlined,
            tint: AppColors.primary,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                'Informe ou toque em uma dose estudada.',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 5),
              Text(
                'O app calcula o volume e cruza a prescrição com o perfil temporal mais próximo da literatura.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ]),
          )
        else ...[
          _PrescriptionResult(estimate: estimate, technique: technique),
          _TimeProfile(estimate: estimate),
          if (estimate.adjuvants.isNotEmpty) _AdjuvantResults(items: estimate.adjuvants),
          if (estimate.alerts.isNotEmpty) _Alerts(items: estimate.alerts),
          ClinicalCard(
            title: 'Contexto da evidência',
            icon: Icons.science_outlined,
            trailing: const EvidenceBadge(EvidenceKind.estimate),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(estimate.profile.evidenceContext),
              if (technique == 'CSE') ...[
                const SizedBox(height: 7),
                const Text(
                  'CSE mantém possibilidade de suplementação epidural; as faixas intratecais não são automaticamente prolongadas.',
                ),
              ],
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: EvidenceButton(referenceIds: estimate.referenceIds),
              ),
            ]),
          ),
        ],
      ]),
    );
  }

  Widget _numberField(TextEditingController controller, String label, String suffix) => TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]'))],
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(labelText: label, suffixText: suffix),
      );

  Widget _quickAdjuvant(String label, TextEditingController controller, double value) => ActionChip(
        label: Text(label),
        onPressed: () {
          controller.text = formatNumber(value);
          setState(() {});
        },
      );
}

class _StudiedDoseChips extends StatelessWidget {
  const _StudiedDoseChips({required this.profile, required this.onSelected});

  final SpinalDrugProfile profile;
  final ValueChanged<double> onSelected;

  @override
  Widget build(BuildContext context) {
    final values = switch (profile.id) {
      'hyperbaric-bupivacaine' => <double>[8, 9, 10, 12],
      'isobaric-bupivacaine' => <double>[8, 10, 12, 13],
      'isobaric-ropivacaine' => <double>[10, 15, 20, 25],
      _ => <double>[7, 7.5, 8, 10],
    };
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Doses estudadas', style: Theme.of(context).textTheme.labelMedium),
      const SizedBox(height: 5),
      Wrap(
        spacing: 7,
        runSpacing: 7,
        children: [
          for (final value in values)
            ActionChip(label: Text('${formatNumber(value)} mg'), onPressed: () => onSelected(value)),
        ],
      ),
      const SizedBox(height: 6),
      Text(
        'Referência populacional; não representa dose recomendada para a paciente.',
        style: Theme.of(context).textTheme.bodySmall,
      ),
    ]);
  }
}

class _PrescriptionResult extends StatelessWidget {
  const _PrescriptionResult({required this.estimate, required this.technique});

  final SpinalEstimate estimate;
  final String technique;

  @override
  Widget build(BuildContext context) {
    final profile = estimate.profile;
    final doseLabel = switch (estimate.dosePosition) {
      DosePosition.belowStudied => 'Abaixo da faixa principal',
      DosePosition.withinStudied => 'Dentro da faixa estudada',
      DosePosition.aboveStudied => 'Acima da faixa principal',
    };
    final doseColor = estimate.dosePosition == DosePosition.withinStudied
        ? AppColors.success
        : AppColors.warning;
    return ClinicalCard(
      title: profile.label,
      icon: Icons.calculate_outlined,
      trailing: const EvidenceBadge(EvidenceKind.calculation),
      child: Column(children: [
        Row(children: [
          Expanded(child: MetricTile(label: 'Dose prescrita', value: '${formatNumber(estimate.doseMg)} mg')),
          const SizedBox(width: 10),
          Expanded(
            child: MetricTile(
              label: 'Volume',
              value: '${formatNumber(estimate.volumeMl, 2)} mL',
              color: AppColors.primary,
            ),
          ),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(
            child: MetricTile(
              label: 'Concentração',
              value: '${formatNumber(estimate.concentrationMgMl)} mg/mL',
              note: '${formatNumber(estimate.concentrationMgMl / 10, 2)}%',
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: MetricTile(label: 'Via / técnica', value: 'Intratecal', note: technique)),
        ]),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: doseColor.withOpacity(.08), borderRadius: BorderRadius.circular(14)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(doseLabel, style: TextStyle(fontWeight: FontWeight.w800, color: doseColor)),
            Text(
              'Principal faixa revisada: ${formatNumber(profile.studiedMinMg)}–${formatNumber(profile.studiedMaxMg)} mg',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ]),
        ),
      ]),
    );
  }
}

class _TimeProfile extends StatelessWidget {
  const _TimeProfile({required this.estimate});

  final SpinalEstimate estimate;

  @override
  Widget build(BuildContext context) {
    final profile = estimate.profile;
    return ClinicalCard(
      title: 'Perfil temporal esperado',
      icon: Icons.hourglass_bottom,
      trailing: const EvidenceBadge(EvidenceKind.estimate),
      tint: AppColors.warning,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        LayoutBuilder(builder: (context, constraints) {
          final width = (constraints.maxWidth - 10) / 2;
          return Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final item in [
                profile.latency,
                profile.surgicalDuration,
                profile.sensoryRegression,
                profile.motorRegression,
              ])
                SizedBox(
                  width: width,
                  child: MetricTile(
                    label: item.label,
                    value: '≈ ${item.minMinutes}–${item.maxMinutes} min',
                    note: item.endpoint,
                    color: AppColors.warning,
                  ),
                ),
            ],
          );
        }),
        const SizedBox(height: 10),
        Text(
          estimate.dosePosition == DosePosition.withinStudied
              ? 'Faixa populacional compatível com a prescrição informada. Confirmar nível antes da incisão e reavaliar clinicamente durante todo o procedimento.'
              : 'A dose informada está fora da principal faixa revisada. Estes tempos descrevem a literatura e não devem ser extrapolados para esta prescrição.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ]),
    );
  }
}

class _AdjuvantResults extends StatelessWidget {
  const _AdjuvantResults({required this.items});

  final List<AdjuvantInterpretation> items;

  @override
  Widget build(BuildContext context) {
    return ClinicalCard(
      title: 'Efeito dos adjuvantes',
      icon: Icons.add_reaction_outlined,
      trailing: const EvidenceBadge(EvidenceKind.estimate),
      child: Column(children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(
                  child: Text(
                    '${item.name} ${formatNumber(item.doseMcg)} mcg',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                Flexible(
                  child: Text(
                    item.summary,
                    textAlign: TextAlign.end,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: item.warning == null ? AppColors.success : AppColors.warning,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ]),
              const SizedBox(height: 4),
              Text(item.details),
              if (item.warning != null) ...[
                const SizedBox(height: 4),
                Text(
                  item.warning!,
                  style: const TextStyle(color: AppColors.warning, fontWeight: FontWeight.w600),
                ),
              ],
            ]),
          ),
      ]),
    );
  }
}

class _Alerts extends StatelessWidget {
  const _Alerts({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return ClinicalCard(
      title: 'Pontos de atenção',
      icon: Icons.warning_amber_rounded,
      tint: AppColors.warning,
      child: Column(children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 7),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.arrow_right, size: 20, color: AppColors.warning),
              const SizedBox(width: 4),
              Expanded(child: Text(item)),
            ]),
          ),
      ]),
    );
  }
}
