import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/models.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class RiskSafetyScreen extends StatefulWidget {
  const RiskSafetyScreen({super.key});
  @override
  State<RiskSafetyScreen> createState() => _RiskSafetyScreenState();
}

class _RiskSafetyScreenState extends State<RiskSafetyScreen> {
  late final TextEditingController platelets;
  bool initialized = false;
  bool knownEtiology = true;
  bool bleedingOrDic = false;
  String anticoagulant = 'Enoxaparina profilática';
  DateTime lastDose = DateTime.now();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (initialized) return;
    platelets = TextEditingController(text: AppScope.of(context).patient.plateletsThousands?.toString() ?? '');
    initialized = true;
  }

  @override
  void dispose() { platelets.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final count = int.tryParse(platelets.text);
    final plateletResult = _plateletText(count);
    final rule = _anticoagulantRules[anticoagulant]!;
    final eligibleAt = lastDose.add(Duration(hours: rule.$1));
    return AppPage(
      title: 'Risco & segurança',
      child: ResponsiveBody(children: [
        ClinicalCard(title: 'Plaquetas / neuroeixo', icon: Icons.bloodtype_outlined, trailing: const EvidenceBadge(EvidenceKind.guideline), child: Column(children: [
          TextField(
            controller: platelets,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (value) {
              final state = AppScope.of(context);
              state.updatePatient(() => state.patient.plateletsThousands = int.tryParse(value));
              setState(() {});
            },
            decoration: const InputDecoration(labelText: 'Plaquetas', suffixText: 'mil/mm³'),
          ),
          const SizedBox(height: 6),
          SwitchListTile.adaptive(contentPadding: EdgeInsets.zero, title: const Text('Etiologia conhecida / doença hipertensiva confirmada'), value: knownEtiology, onChanged: (v) => setState(() => knownEtiology = v)),
          SwitchListTile.adaptive(contentPadding: EdgeInsets.zero, title: const Text('Sangramento relevante ou sinais de DIC'), value: bleedingOrDic, onChanged: (v) => setState(() => bleedingOrDic = v)),
          if (count != null) ...[const SizedBox(height: 6), MetricTile(label: plateletResult.$1, value: plateletResult.$2, note: plateletResult.$3, color: plateletResult.$4)],
          const SizedBox(height: 8),
          Row(children: [const Text('Fonte declarada: SOAP 2021'), const Spacer(), EvidenceButton(referenceIds: const ['soap-platelets-2021'])]),
        ])),
        ClinicalCard(title: 'Anticoagulação e neuroeixo', icon: Icons.shield_outlined, trailing: const EvidenceBadge(EvidenceKind.guideline), child: Column(children: [
          DropdownButtonFormField<String>(value: anticoagulant, decoration: const InputDecoration(labelText: 'Medicamento / regime'), items: _anticoagulantRules.keys.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(), onChanged: (v) => setState(() => anticoagulant = v!)),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () async {
              final selected = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(lastDose));
              if (selected != null) setState(() => lastDose = DateTime(lastDose.year, lastDose.month, lastDose.day, selected.hour, selected.minute));
            },
            icon: const Icon(Icons.schedule), label: Text('Última dose: ${formatClock(lastDose)}'),
          ),
          const SizedBox(height: 10),
          MetricTile(label: 'Punção / manipulação', value: rule.$1 == 0 ? 'Sem intervalo específico' : 'Após ≥ ${rule.$1} h', note: rule.$1 == 0 ? rule.$2 : 'Horário calculado: ${formatClock(eligibleAt)}'),
          const SizedBox(height: 10),
          MetricTile(label: 'Cateter / reinício', value: rule.$2, note: 'ASRA 5ª edição (2025)'),
          const SizedBox(height: 8),
          Row(children: [const Text('Fonte declarada: ASRA 2025'), const Spacer(), EvidenceButton(referenceIds: const ['asra-antithrombotic-2025'])]),
        ])),
        ClinicalCard(title: 'Em preparação', icon: Icons.pending_actions_outlined, trailing: const EvidenceBadge(EvidenceKind.pending), child: const Wrap(spacing: 8, runSpacing: 8, children: [
          Chip(label: Text('Hemorragia')), Chip(label: Text('Índice de choque')), Chip(label: Text('Cardiovascular')), Chip(label: Text('TEV')), Chip(label: Text('Obesidade')), Chip(label: Text('Pré-eclâmpsia')), Chip(label: Text('Via aérea')),
        ])),
      ]),
    );
  }

  (String, String, String, Color) _plateletText(int? count) {
    if (count == null) return ('Contexto', 'Informe a contagem', '', Colors.grey);
    if (bleedingOrDic) return ('Alerta', 'Evitar / avaliação hematológica', 'SOAP: história de sangramento ou DIC modifica a decisão, independentemente da contagem.', AppColors.danger);
    if (!knownEtiology && count < 70) return ('Contexto', 'Investigação adicional', 'Etiologia desconhecida e <70k: avaliação hematológica pode ser benéfica antes do neuroeixo.', AppColors.warning);
    if (count >= 70) return ('Faixa', '≥70 mil/mm³', 'Risco provavelmente muito baixo; razoável proceder se clinicamente indicado e sem fatores adicionais.', AppColors.success);
    if (count >= 50) return ('Faixa', '50–70 mil/mm³', 'Riscos/benefícios concorrentes podem justificar o neuroeixo em cenários selecionados.', AppColors.warning);
    return ('Faixa', '<50 mil/mm³', 'Risco provavelmente maior; pode ser razoável evitar procedimento neuroaxial.', AppColors.danger);
  }

  static const _anticoagulantRules = <String, (int, String)>{
    'Enoxaparina profilática': (12, 'Retirar cateter ≥12 h após última dose; reiniciar ≥4 h após retirada.'),
    'Enoxaparina terapêutica': (24, 'Retirar cateter ≥4 h antes da primeira dose; reinício terapêutico depende do risco hemorrágico e deve respeitar ≥24 h da punção.'),
    'Heparina SC baixa dose': (4, 'Janela de 4–6 h e avaliação da coagulação; reinício conforme ASRA/protocolo.'),
    'AAS isolado': (0, 'AAS/NSAID isolado não exige intervalo específico; combinações e plaquetopenia requerem avaliação individual.'),
  };
}
