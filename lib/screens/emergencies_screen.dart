import 'package:flutter/material.dart';

import '../clinical_data/emergency_protocols.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class EmergenciesScreen extends StatefulWidget {
  const EmergenciesScreen({super.key});

  @override
  State<EmergenciesScreen> createState() => _EmergenciesScreenState();
}

class _EmergenciesScreenState extends State<EmergenciesScreen> {
  EmergencyProtocol? selected;

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Emergências',
      child: ResponsiveBody(children: [
        DropdownButtonFormField<EmergencyProtocol?>(
          value: selected,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Protocolo rápido',
            prefixIcon: Icon(Icons.emergency_outlined),
          ),
          items: [
            const DropdownMenuItem<EmergencyProtocol?>(
              value: null,
              child: Text('Todos os protocolos'),
            ),
            ...EmergencyProtocols.all.map(
              (item) => DropdownMenuItem<EmergencyProtocol?>(
                value: item,
                child: Text(item.title),
              ),
            ),
          ],
          onChanged: (value) => setState(() => selected = value),
        ),
        const SizedBox(height: 6),
        if (selected == null)
          for (final protocol in EmergencyProtocols.all)
            Card(
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  backgroundColor: AppColors.danger.withOpacity(.10),
                  foregroundColor: AppColors.danger,
                  child: Icon(protocol.icon),
                ),
                title: Text(protocol.title, style: const TextStyle(fontWeight: FontWeight.w800)),
                subtitle: Text(protocol.subtitle),
                trailing: const Icon(Icons.expand_more),
                onTap: () => setState(() => selected = protocol),
              ),
            )
        else
          _ProtocolDetail(protocol: selected!),
      ]),
    );
  }
}

class _ProtocolDetail extends StatelessWidget {
  const _ProtocolDetail({required this.protocol});

  final EmergencyProtocol protocol;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(children: [
        Expanded(
          child: Text(
            protocol.title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
        ),
        EvidenceBadge(protocol.reviewPending ? EvidenceKind.pending : EvidenceKind.guideline),
      ]),
      Align(
        alignment: Alignment.centerRight,
        child: EvidenceButton(referenceIds: protocol.referenceIds),
      ),
      for (var i = 0; i < protocol.steps.length; i++) ...[
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: protocol.steps[i].danger
                ? AppColors.danger.withOpacity(.08)
                : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: protocol.steps[i].danger
                  ? AppColors.danger.withOpacity(.35)
                  : Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              protocol.steps[i].label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: protocol.steps[i].danger ? AppColors.danger : null,
                  ),
            ),
            const SizedBox(height: 8),
            for (final item in protocol.steps[i].items)
              Padding(
                padding: const EdgeInsets.only(bottom: 7),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Icon(
                    Icons.arrow_right,
                    size: 20,
                    color: protocol.steps[i].danger ? AppColors.danger : AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Expanded(child: Text(item)),
                ]),
              ),
          ]),
        ),
        if (i < protocol.steps.length - 1)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 5),
              child: Icon(Icons.keyboard_arrow_down, color: Colors.grey),
            ),
          ),
      ],
    ]);
  }
}
