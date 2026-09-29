import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/models.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class EpiduralTimelineScreen extends StatefulWidget {
  const EpiduralTimelineScreen({super.key, this.embedded = false});
  final bool embedded;
  @override
  State<EpiduralTimelineScreen> createState() => _EpiduralTimelineScreenState();
}

class _EpiduralTimelineScreenState extends State<EpiduralTimelineScreen> {
  Timer? timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 30), (_) { if (mounted) setState(() {}); });
  }

  @override
  void dispose() { timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final catheter = state.catheter;
    final boluses = state.boluses.reversed.toList();
    final content = ResponsiveBody(children: [
        ClinicalCard(title: 'Instalação', icon: Icons.medical_information_outlined, child: Column(children: [
          Row(children: [
            Expanded(child: _simpleField('Nível', catheter.punctureLevel, (v) => state.updateCatheter(() => catheter.punctureLevel = v))),
            const SizedBox(width: 10),
            Expanded(child: _numberField('Espaço', catheter.spaceDepthCm, 'cm', (v) => state.updateCatheter(() => catheter.spaceDepthCm = v))),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: _numberField('Introduzido', catheter.catheterThreadedCm, 'cm', (v) => state.updateCatheter(() => catheter.catheterThreadedCm = v))),
            const SizedBox(width: 10),
            Expanded(child: _numberField('Na pele', catheter.skinMarkCm, 'cm', (v) => state.updateCatheter(() => catheter.skinMarkCm = v))),
          ]),
          const SizedBox(height: 10),
          _simpleField('Teste realizado', catheter.test, (v) => state.updateCatheter(() => catheter.test = v)),
        ])),
        if (boluses.isEmpty)
          ClinicalCard(title: 'Linha do tempo', icon: Icons.timeline, child: Column(children: [
            const Icon(Icons.schedule_outlined, size: 42, color: Colors.grey),
            const SizedBox(height: 8),
            const Text('Nenhuma administração registrada.'),
            const SizedBox(height: 12),
            FilledButton.icon(onPressed: () => _addBolus(context), icon: const Icon(Icons.add), label: const Text('Registrar bolus / repique')),
          ]))
        else ...[
          ClinicalCard(title: 'Agora', icon: Icons.timer_outlined, trailing: const EvidenceBadge(EvidenceKind.estimate), child: _CurrentDose(record: boluses.first)),
          ClinicalCard(title: 'Histórico', icon: Icons.history, child: Column(children: [for (final record in boluses) _TimelineEntry(record: record)])),
        ],
        const SizedBox(height: 6),
        FilledButton.icon(onPressed: () => _addBolus(context), icon: const Icon(Icons.add), label: const Text('Registrar nova administração')),
      ]);
    if (widget.embedded) return content;
    return AppPage(
      title: 'Cateter e linha do tempo',
      actions: [IconButton(tooltip: 'Registrar dose', icon: const Icon(Icons.add_circle_outline), onPressed: () => _addBolus(context))],
      child: content,
    );
  }

  Widget _simpleField(String label, String? value, ValueChanged<String> onChanged) => TextFormField(initialValue: value, decoration: InputDecoration(labelText: label), onChanged: onChanged);

  Widget _numberField(String label, double? value, String suffix, ValueChanged<double?> onChanged) => TextFormField(
    initialValue: value?.toString(),
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]'))],
    decoration: InputDecoration(labelText: label, suffixText: suffix),
    onChanged: (v) => onChanged(parseNumber(v)),
  );

  Future<void> _addBolus(BuildContext context) async {
    final record = await showModalBottomSheet<BolusRecord>(context: context, isScrollControlled: true, showDragHandle: true, builder: (_) => const _BolusEditor());
    if (record != null && context.mounted) AppScope.of(context).addBolus(record);
  }
}

class _CurrentDose extends StatelessWidget {
  const _CurrentDose({required this.record});
  final BolusRecord record;

  @override
  Widget build(BuildContext context) {
    final elapsed = DateTime.now().difference(record.administeredAt);
    final mins = elapsed.isNegative ? 0 : elapsed.inMinutes;
    return Column(children: [
      Row(children: [Expanded(child: MetricTile(label: 'Última dose', value: formatClock(record.administeredAt))), const SizedBox(width: 10), Expanded(child: MetricTile(label: 'Decorrido', value: '$mins min'))]),
      const SizedBox(height: 10),
      Row(children: [Expanded(child: MetricTile(label: 'Reavaliar por volta de', value: '~${formatClock(record.reassessAt)}', color: AppColors.warning)), const SizedBox(width: 10), Expanded(child: MetricTile(label: 'Janela informada', value: '${formatClock(record.reassessAt)}–${formatClock(record.windowEnd)}'))]),
      const SizedBox(height: 10),
      Text('Tempo estimado a partir da faixa informada. Reavaliar nível de analgesia e condições materno-fetais antes de nova administração.', style: Theme.of(context).textTheme.bodySmall),
    ]);
  }
}

class _TimelineEntry extends StatelessWidget {
  const _TimelineEntry({required this.record});
  final BolusRecord record;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Column(children: [Container(width: 12, height: 12, decoration: const BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle)), Container(width: 2, height: 62, color: Theme.of(context).colorScheme.outlineVariant)]),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${formatClock(record.administeredAt)} • ${record.indication}', style: const TextStyle(fontWeight: FontWeight.w800)),
          Text('${record.drug} ${formatNumber(record.concentrationMgMl, 3)} mg/mL • ${formatNumber(record.volumeMl)} mL'),
          Text('${formatNumber(record.localAnestheticMg)} mg${record.opioidMcg > 0 ? ' • ${formatNumber(record.opioidMcg)} mcg opioide' : ''}'),
          Text('Reavaliar ~${formatClock(record.reassessAt)} • janela até ${formatClock(record.windowEnd)}', style: Theme.of(context).textTheme.bodySmall),
        ])),
      ]),
    );
  }
}

class _BolusEditor extends StatefulWidget {
  const _BolusEditor();
  @override
  State<_BolusEditor> createState() => _BolusEditorState();
}

class _BolusEditorState extends State<_BolusEditor> {
  String indication = 'Bolus inicial';
  String method = 'Manual';
  String drug = 'Bupivacaína';
  DateTime time = DateTime.now();
  final concentration = TextEditingController();
  final volume = TextEditingController();
  final opioid = TextEditingController();
  final min = TextEditingController();
  final max = TextEditingController();

  @override
  void dispose() {
    for (final item in [concentration, volume, opioid, min, max]) { item.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, bottom + 20),
      child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('Registrar administração', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 14),
        DropdownButtonFormField<String>(value: indication, decoration: const InputDecoration(labelText: 'Indicação'), items: _indications.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(), onChanged: (v) => setState(() => indication = v!)),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: DropdownButtonFormField<String>(value: drug, decoration: const InputDecoration(labelText: 'Fármaco'), items: ['Bupivacaína', 'Ropivacaína', 'Levobupivacaína', 'Lidocaína'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(), onChanged: (v) => setState(() => drug = v!))),
          const SizedBox(width: 10),
          Expanded(child: DropdownButtonFormField<String>(value: method, decoration: const InputDecoration(labelText: 'Método'), items: ['Manual', 'PIEB', 'PCEA', 'Infusão'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(), onChanged: (v) => setState(() => method = v!))),
        ]),
        const SizedBox(height: 10),
        Row(children: [Expanded(child: _field(concentration, 'Concentração', 'mg/mL')), const SizedBox(width: 10), Expanded(child: _field(volume, 'Volume', 'mL'))]),
        const SizedBox(height: 10),
        _field(opioid, 'Opioide na solução', 'mcg/mL'),
        const SizedBox(height: 10),
        Row(children: [Expanded(child: _field(min, 'Efeito mínimo', 'min', integer: true)), const SizedBox(width: 10), Expanded(child: _field(max, 'Efeito máximo', 'min', integer: true))]),
        const SizedBox(height: 6),
        Text('Faixa temporal informada pelo usuário/protocolo local; não sugerida automaticamente.', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () async {
            final selected = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(time));
            if (selected != null) setState(() => time = DateTime(time.year, time.month, time.day, selected.hour, selected.minute));
          },
          icon: const Icon(Icons.schedule), label: Text('Horário: ${formatClock(time)}'),
        ),
        const SizedBox(height: 12),
        FilledButton(onPressed: _valid ? _save : null, child: const Text('Adicionar à linha do tempo')),
      ])),
    );
  }

  bool get _valid {
    final conc = parseNumber(concentration.text);
    final vol = parseNumber(volume.text);
    final lo = int.tryParse(min.text);
    final hi = int.tryParse(max.text);
    return conc != null && conc > 0 && vol != null && vol > 0 && lo != null && lo > 0 && hi != null && hi >= lo;
  }

  void _save() {
    Navigator.pop(context, BolusRecord(
      id: DateTime.now().microsecondsSinceEpoch.toString(), administeredAt: time, indication: indication, method: method, drug: drug,
      concentrationMgMl: parseNumber(concentration.text)!, volumeMl: parseNumber(volume.text)!, opioidMcgMl: parseNumber(opioid.text) ?? 0,
      expectedMinMinutes: int.parse(min.text), expectedMaxMinutes: int.parse(max.text),
    ));
  }

  Widget _field(TextEditingController controller, String label, String suffix, {bool integer = false}) => TextField(
    controller: controller,
    onChanged: (_) => setState(() {}),
    keyboardType: TextInputType.numberWithOptions(decimal: !integer),
    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(integer ? r'[0-9]' : r'[0-9,.]'))],
    decoration: InputDecoration(labelText: label, suffixText: suffix),
  );

  static const _indications = ['Bolus inicial', 'Analgesia insuficiente', 'Bloqueio unilateral', 'Breakthrough pain', 'Progressão do trabalho de parto', 'Instrumentação', 'Conversão para cesárea', 'Outro'];
}
