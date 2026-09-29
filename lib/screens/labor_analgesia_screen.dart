import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../calculations/clinical_math.dart';
import '../models/models.dart';
import '../widgets/common.dart';
import 'epidural_timeline_screen.dart';

class LaborAnalgesiaScreen extends StatefulWidget {
  const LaborAnalgesiaScreen({super.key});
  @override
  State<LaborAnalgesiaScreen> createState() => _LaborAnalgesiaScreenState();
}

class _LaborAnalgesiaScreenState extends State<LaborAnalgesiaScreen> {
  String technique = 'Peridural';
  String section = 'Analgesia';
  String mode = 'PIEB';
  String drug = 'Bupivacaína';
  final local = TextEditingController();
  final opioid = TextEditingController();
  final volume = TextEditingController();
  final interval = TextEditingController();

  @override
  void dispose() {
    for (final item in [local, opioid, volume, interval]) { item.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (section == 'Cateter') {
      return AppPage(
        title: 'Analgesia de parto',
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'Analgesia', label: Text('Analgesia')),
                ButtonSegment(value: 'Cateter', label: Text('Cateter / tempo')),
              ],
              selected: {section},
              onSelectionChanged: (value) => setState(() => section = value.first),
            ),
          ),
          const Expanded(child: EpiduralTimelineScreen(embedded: true)),
        ]),
      );
    }
    final localMgMl = parseNumber(local.text);
    final opioidMcgMl = parseNumber(opioid.text) ?? 0;
    final volumeMl = parseNumber(volume.text);
    final intervalMin = int.tryParse(interval.text);
    PiebResult? pieb;
    PceaResult? pcea;
    if (localMgMl != null && volumeMl != null && intervalMin != null && intervalMin > 0) {
      if (mode == 'PIEB') {
        pieb = ClinicalMath.pieb(volumeMl: volumeMl, intervalMinutes: intervalMin, localMgMl: localMgMl, opioidMcgMl: opioidMcgMl);
      } else if (mode == 'PCEA') {
        pcea = ClinicalMath.pcea(demandVolumeMl: volumeMl, lockoutMinutes: intervalMin, localMgMl: localMgMl, opioidMcgMl: opioidMcgMl);
      }
    }
    return AppPage(
      title: 'Analgesia de parto',
      child: ResponsiveBody(children: [
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'Analgesia', label: Text('Analgesia')),
            ButtonSegment(value: 'Cateter', label: Text('Cateter / tempo')),
          ],
          selected: {section},
          onSelectionChanged: (value) => setState(() => section = value.first),
        ),
        ClinicalCard(title: 'Técnica', icon: Icons.route_outlined, child: SegmentedButton<String>(
          segments: const [ButtonSegment(value: 'Peridural', label: Text('Peridural')), ButtonSegment(value: 'CSE', label: Text('CSE')), ButtonSegment(value: 'DPE', label: Text('DPE'))],
          selected: {technique},
          onSelectionChanged: (value) => setState(() => technique = value.first),
        )),
        ClinicalCard(title: 'Solução e manutenção', icon: Icons.science_outlined, trailing: const EvidenceBadge(EvidenceKind.calculation), child: Column(children: [
          Row(children: [
            Expanded(child: DropdownButtonFormField<String>(value: drug, decoration: const InputDecoration(labelText: 'Anestésico local'), items: ['Bupivacaína', 'Ropivacaína', 'Levobupivacaína'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(), onChanged: (v) => setState(() => drug = v!))),
            const SizedBox(width: 10),
            Expanded(child: DropdownButtonFormField<String>(value: mode, decoration: const InputDecoration(labelText: 'Método'), items: ['Bolus', 'Infusão', 'PIEB', 'PCEA'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(), onChanged: (v) => setState(() => mode = v!))),
          ]),
          const SizedBox(height: 10),
          Row(children: [Expanded(child: _field(local, 'Concentração', 'mg/mL')), const SizedBox(width: 10), Expanded(child: _field(opioid, 'Opioide', 'mcg/mL'))]),
          const SizedBox(height: 10),
          Row(children: [Expanded(child: _field(volume, mode == 'PCEA' ? 'Volume/demanda' : 'Volume/bolus', 'mL')), const SizedBox(width: 10), Expanded(child: _field(interval, mode == 'PCEA' ? 'Lockout' : 'Intervalo', 'min', integer: true))]),
          const SizedBox(height: 8),
          Text('Informe a concentração do protocolo local. O app executa apenas a matemática da solução.', style: Theme.of(context).textTheme.bodySmall),
        ])),
        if (pieb != null)
          ClinicalCard(title: 'PIEB', child: _grid([MetricTile(label: 'Por bolus', value: '${formatNumber(pieb.localMgPerBolus)} mg'), MetricTile(label: 'Opioide/bolus', value: '${formatNumber(pieb.opioidMcgPerBolus)} mcg'), MetricTile(label: 'Média teórica', value: '${formatNumber(pieb.averageMlPerHour)} mL/h'), MetricTile(label: 'Média teórica', value: '${formatNumber(pieb.averageLocalMgPerHour)} mg/h')])),
        if (pcea != null)
          ClinicalCard(title: 'PCEA — máximo teórico', child: Column(children: [
            const Align(alignment: Alignment.centerLeft, child: EvidenceBadge(EvidenceKind.calculation)),
            const SizedBox(height: 8),
            _grid([MetricTile(label: 'Demandas/h', value: '${pcea.maxDemandsPerHour}'), MetricTile(label: 'Máximo', value: '${formatNumber(pcea.maximumMlPerHour)} mL/h'), MetricTile(label: 'Máximo', value: '${formatNumber(pcea.maximumLocalMgPerHour)} mg/h'), MetricTile(label: 'Opioide máximo', value: '${formatNumber(pcea.maximumOpioidMcgPerHour)} mcg/h')]),
            const SizedBox(height: 8),
            Text('Máximo teórico pelo lockout; não representa dose administrada.', style: Theme.of(context).textTheme.bodySmall),
          ])),
      ]),
    );
  }

  Widget _field(TextEditingController controller, String label, String suffix, {bool integer = false}) => TextField(
    controller: controller,
    onChanged: (_) => setState(() {}),
    keyboardType: TextInputType.numberWithOptions(decimal: !integer),
    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(integer ? r'[0-9]' : r'[0-9,.]'))],
    decoration: InputDecoration(labelText: label, suffixText: suffix),
  );

  Widget _grid(List<Widget> tiles) => LayoutBuilder(builder: (context, constraints) {
    final width = (constraints.maxWidth - 10) / 2;
    return Wrap(spacing: 10, runSpacing: 10, children: [for (final tile in tiles) SizedBox(width: width, child: tile)]);
  });
}
