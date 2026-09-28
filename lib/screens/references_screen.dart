import 'package:flutter/material.dart';

import '../clinical_data/evidence_catalog.dart';
import '../models/models.dart';
import '../widgets/common.dart';

class ReferencesScreen extends StatelessWidget {
  const ReferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final groups = <String, List<EvidenceReference>>{};
    for (final ref in EvidenceCatalog.references) { groups.putIfAbsent(ref.group, () => []).add(ref); }
    return AppPage(title: 'Referências', showPatient: false, child: ResponsiveBody(children: [
      for (final entry in groups.entries)
        ClinicalCard(title: entry.key, icon: Icons.menu_book_outlined, child: Column(children: [
          for (final ref in entry.value)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(ref.title, style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text('${ref.authors} • ${ref.year}${ref.doi == null ? '' : '\nDOI ${ref.doi}'}${ref.pmid == null ? '' : ' • PMID ${ref.pmid}'}\nRevisado no app: 28/09/2026'),
              trailing: const Icon(Icons.info_outline),
              onTap: () => showEvidenceSheet(context, [ref.id]),
            ),
        ])),
      ClinicalCard(title: 'Matriz clínica interna', icon: Icons.table_chart_outlined, child: Column(children: [
        for (final row in EvidenceCatalog.matrix)
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: Text(row.variable, style: const TextStyle(fontWeight: FontWeight.w700)),
            subtitle: Text(row.exposure),
            childrenPadding: const EdgeInsets.only(bottom: 12),
            children: [Align(alignment: Alignment.centerLeft, child: Text('População: ${row.population}\nTécnica: ${row.technique}\nDesfecho: ${row.outcome}\nEstimativa: ${row.estimate}\nObservações: ${row.notes}'))],
          ),
      ])),
    ]));
  }
}
