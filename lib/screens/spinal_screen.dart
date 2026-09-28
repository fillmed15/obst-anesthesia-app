import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../calculations/clinical_math.dart';
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
  String drug = 'Bupivacaína hiperbárica';
  final concentration = TextEditingController(text: '5');
  final dose = TextEditingController();
  final fentanyl = TextEditingController();
  final morphine = TextEditingController();
  final sufentanil = TextEditingController();

  @override
  void dispose() {
    for (final item in [concentration, dose, fentanyl, morphine, sufentanil]) { item.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final conc = parseNumber(concentration.text);
    final selectedDose = parseNumber(dose.text);
    final volume = conc != null && conc > 0 && selectedDose != null ? ClinicalMath.volumeFromDose(dose: selectedDose, concentration: conc) : null;
    final validated = drug == 'Bupivacaína hiperbárica';
    return AppPage(
      title: 'Raquianestesia',
      child: ResponsiveBody(children: [
        ClinicalCard(title: 'Técnica e fármaco', icon: Icons.medication_liquid_outlined, child: Column(children: [
          SegmentedButton<String>(
            segments: const [ButtonSegment(value: 'Raquianestesia', label: Text('Raqui')), ButtonSegment(value: 'CSE', label: Text('CSE'))],
            selected: {technique},
            onSelectionChanged: (value) => setState(() => technique = value.first),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: drug,
            decoration: const InputDecoration(labelText: 'Anestésico local'),
            items: _drugs.map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
            onChanged: (value) => setState(() { drug = value!; concentration.text = drug == 'Bupivacaína hiperbárica' ? '5' : ''; }),
          ),
          const SizedBox(height: 10),
          Row(children: [Expanded(child: _numberField(concentration, 'Concentração', 'mg/mL')), const SizedBox(width: 10), Expanded(child: _numberField(dose, 'Dose escolhida', 'mg'))]),
          const SizedBox(height: 8),
          Align(alignment: Alignment.centerLeft, child: Text('A dose é sempre informada pelo usuário. Peso, altura e IMC não geram dose automática.', style: Theme.of(context).textTheme.bodySmall)),
        ])),
        if (volume != null)
          ClinicalCard(title: drug, icon: Icons.calculate_outlined, trailing: const EvidenceBadge(EvidenceKind.calculation), child: Column(children: [
            Row(children: [Expanded(child: MetricTile(label: 'Dose', value: '${formatNumber(selectedDose!)} mg')), const SizedBox(width: 10), Expanded(child: MetricTile(label: 'Volume', value: '${formatNumber(volume, 2)} mL', color: AppColors.primary))]),
            const SizedBox(height: 10),
            const MetricTile(label: 'Via', value: 'Intratecal'),
          ])),
        ClinicalCard(title: 'Adjuvantes', icon: Icons.add_circle_outline, child: Column(children: [
          Row(children: [Expanded(child: _numberField(fentanyl, 'Fentanil', 'mcg')), const SizedBox(width: 10), Expanded(child: _numberField(morphine, 'Morfina', 'mcg'))]),
          const SizedBox(height: 10),
          _numberField(sufentanil, 'Sufentanil', 'mcg'),
          const SizedBox(height: 10),
          Row(children: [const EvidenceBadge(EvidenceKind.guideline), const Spacer(), EvidenceButton(referenceIds: validated ? const ['soap-erac-2021', 'li-fentanyl-2025'] : const ['soap-erac-2021'])]),
          const SizedBox(height: 6),
          Text('Faixas publicadas são exibidas na evidência; o app não seleciona uma dose pela paciente.', style: Theme.of(context).textTheme.bodySmall),
        ])),
        ClinicalCard(title: 'Informações do bloqueio', icon: Icons.hourglass_bottom, trailing: const EvidenceBadge(EvidenceKind.pending), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const MetricTile(label: 'Latência / duração / regressão', value: 'Não automatizadas', note: 'Dados insuficientes para automatização segura neste build.'),
          if (!validated) ...[const SizedBox(height: 8), Text('$drug permanece disponível para estruturar o fluxo, mas sem dados clínicos até revisão dedicada.', style: Theme.of(context).textTheme.bodySmall)],
        ])),
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

  static const _drugs = ['Bupivacaína hiperbárica', 'Bupivacaína isobárica', 'Ropivacaína', 'Levobupivacaína'];
}
