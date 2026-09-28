import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/models.dart';
import '../services/app_state.dart';
import '../widgets/common.dart';

class PatientScreen extends StatefulWidget {
  const PatientScreen({super.key});
  @override
  State<PatientScreen> createState() => _PatientScreenState();
}

class _PatientScreenState extends State<PatientScreen> {
  final Map<String, TextEditingController> c = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (c.isNotEmpty) return;
    final p = AppScope.of(context).patient;
    c.addAll({
      'id': TextEditingController(text: p.identifier ?? ''),
      'age': TextEditingController(text: p.ageYears?.toString() ?? ''),
      'gw': TextEditingController(text: p.gestationalWeeks?.toString() ?? ''),
      'gd': TextEditingController(text: p.gestationalDays?.toString() ?? ''),
      'weight': TextEditingController(text: p.weightKg?.toString() ?? ''),
      'height': TextEditingController(text: p.heightCm?.toString() ?? ''),
      'parity': TextEditingController(text: p.parity?.toString() ?? ''),
      'sbp': TextEditingController(text: p.systolicBp?.toString() ?? ''),
      'dbp': TextEditingController(text: p.diastolicBp?.toString() ?? ''),
      'hr': TextEditingController(text: p.heartRate?.toString() ?? ''),
      'plq': TextEditingController(text: p.plateletsThousands?.toString() ?? ''),
      'hb': TextEditingController(text: p.hemoglobin?.toString() ?? ''),
    });
  }

  @override
  void dispose() {
    for (final controller in c.values) { controller.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final p = state.patient;
    return AppPage(
      title: 'Paciente',
      showPatient: false,
      child: ResponsiveBody(children: [
        ClinicalCard(title: 'Contexto clínico', icon: Icons.person_outline, child: Column(children: [
          _field('Identificação opcional', c['id']!, (v) => state.updatePatient(() => p.identifier = v.trim())),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: _field('Idade', c['age']!, (v) => state.updatePatient(() => p.ageYears = int.tryParse(v)), suffix: 'anos')),
            const SizedBox(width: 10),
            Expanded(child: _field('Paridade', c['parity']!, (v) => state.updatePatient(() => p.parity = int.tryParse(v)), suffix: 'P')),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: _field('Gestação', c['gw']!, (v) => state.updatePatient(() => p.gestationalWeeks = int.tryParse(v)), suffix: 'sem')),
            const SizedBox(width: 10),
            Expanded(child: _field('Dias', c['gd']!, (v) => state.updatePatient(() => p.gestationalDays = int.tryParse(v)), suffix: 'dias')),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: _field('Peso', c['weight']!, (v) => state.updatePatient(() => p.weightKg = parseNumber(v)), suffix: 'kg', decimal: true)),
            const SizedBox(width: 10),
            Expanded(child: _field('Altura', c['height']!, (v) => state.updatePatient(() => p.heightCm = parseNumber(v)), suffix: 'cm', decimal: true)),
          ]),
          if (p.bmi != null) ...[
            const SizedBox(height: 12),
            const Align(alignment: Alignment.centerLeft, child: EvidenceBadge(EvidenceKind.calculation)),
            const SizedBox(height: 6),
            MetricTile(label: 'IMC', value: '${formatNumber(p.bmi!)} kg/m²'),
          ],
        ])),
        ClinicalCard(title: 'Basal e exames', icon: Icons.monitor_heart_outlined, child: Column(children: [
          Row(children: [
            Expanded(child: _field('PAS', c['sbp']!, (v) => state.updatePatient(() => p.systolicBp = int.tryParse(v)), suffix: 'mmHg')),
            const SizedBox(width: 10),
            Expanded(child: _field('PAD', c['dbp']!, (v) => state.updatePatient(() => p.diastolicBp = int.tryParse(v)), suffix: 'mmHg')),
            const SizedBox(width: 10),
            Expanded(child: _field('FC', c['hr']!, (v) => state.updatePatient(() => p.heartRate = int.tryParse(v)), suffix: 'bpm')),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: _field('Plaquetas', c['plq']!, (v) => state.updatePatient(() => p.plateletsThousands = int.tryParse(v)), suffix: 'mil/mm³')),
            const SizedBox(width: 10),
            Expanded(child: _field('Hemoglobina', c['hb']!, (v) => state.updatePatient(() => p.hemoglobin = parseNumber(v)), suffix: 'g/dL', decimal: true)),
          ]),
          SwitchListTile.adaptive(contentPadding: EdgeInsets.zero, title: const Text('Uso de anticoagulante'), value: p.anticoagulantUse, onChanged: (v) => state.updatePatient(() => p.anticoagulantUse = v)),
        ])),
        ClinicalCard(title: 'Condições especiais', icon: Icons.health_and_safety_outlined, child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _conditions.map((condition) => FilterChip(
            label: Text(condition),
            selected: p.conditions.contains(condition),
            onSelected: (selected) => state.updatePatient(() { selected ? p.conditions.add(condition) : p.conditions.remove(condition); }),
          )).toList(),
        )),
      ]),
    );
  }

  Widget _field(String label, TextEditingController controller, ValueChanged<String> onChanged, {String? suffix, bool decimal = false}) {
    final isText = label.startsWith('Identificação');
    return TextField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: isText ? TextInputType.text : TextInputType.numberWithOptions(decimal: decimal),
      inputFormatters: isText ? null : [FilteringTextInputFormatter.allow(RegExp(decimal ? r'[0-9,.]' : r'[0-9]'))],
      decoration: InputDecoration(labelText: label, suffixText: suffix),
    );
  }

  static const _conditions = ['Pré-eclâmpsia', 'HELLP', 'Obesidade', 'Cardiopatia', 'Hemorragia', 'Placenta prévia/accreta', 'Anticoagulação', 'Coagulopatia', 'Via aérea difícil'];
}
