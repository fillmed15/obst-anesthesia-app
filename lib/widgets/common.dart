import 'package:flutter/material.dart';

import '../clinical_data/evidence_catalog.dart';
import '../models/models.dart';
import '../screens/patient_screen.dart';
import '../screens/references_screen.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';

String formatNumber(double value, [int decimals = 1]) {
  final text = value.toStringAsFixed(decimals);
  return text.replaceFirst(RegExp(r'([.,]0+)$'), '').replaceAll('.', ',');
}

String formatClock(DateTime value) =>
    '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';

double? parseNumber(String value) => double.tryParse(value.trim().replaceAll(',', '.'));

class AppPage extends StatelessWidget {
  const AppPage({super.key, required this.title, required this.child, this.actions = const [], this.showPatient = true});
  final String title;
  final Widget child;
  final List<Widget> actions;
  final bool showPatient;

  @override
  Widget build(BuildContext context) {
    final patient = AppScope.of(context).patient;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title),
          if (showPatient)
            Text(patient.compactSummary, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500)),
        ]),
        actions: [
          ...actions,
          IconButton(
            tooltip: 'Referências',
            icon: const Icon(Icons.menu_book_outlined),
            onPressed: () => showReferencesSheet(context),
          ),
          if (showPatient)
            IconButton(
              tooltip: 'Paciente',
              icon: const Icon(Icons.person_outline),
              onPressed: () => showPatientSheet(context),
            ),
        ],
      ),
      body: SafeArea(child: child),
    );
  }
}

class ClinicalCard extends StatelessWidget {
  const ClinicalCard({super.key, required this.title, required this.child, this.icon, this.trailing, this.tint});
  final String title;
  final Widget child;
  final IconData? icon;
  final Widget? trailing;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: tint == null ? null : Color.alphaBlend(tint!.withOpacity(.06), theme.colorScheme.surface),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            if (icon != null) ...[Icon(icon, size: 20, color: tint ?? theme.colorScheme.primary), const SizedBox(width: 8)],
            Expanded(child: Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700))),
            if (trailing != null) trailing!,
          ]),
          const SizedBox(height: 12),
          child,
        ]),
      ),
    );
  }
}

class MetricTile extends StatelessWidget {
  const MetricTile({super.key, required this.label, required this.value, this.note, this.color});
  final String label;
  final String value;
  final String? note;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: theme.colorScheme.outlineVariant)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        const SizedBox(height: 4),
        Text(value, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800, color: color)),
        if (note != null) ...[const SizedBox(height: 3), Text(note!, style: theme.textTheme.bodySmall)],
      ]),
    );
  }
}

class EvidenceBadge extends StatelessWidget {
  const EvidenceBadge(this.kind, {super.key});
  final EvidenceKind kind;

  @override
  Widget build(BuildContext context) {
    final config = switch (kind) {
      EvidenceKind.calculation => ('Cálculo', Icons.calculate_outlined, AppColors.primary),
      EvidenceKind.estimate => ('Estimativa', Icons.schedule_outlined, AppColors.warning),
      EvidenceKind.guideline => ('Guideline', Icons.fact_check_outlined, AppColors.success),
      EvidenceKind.pending => ('Pendente', Icons.hourglass_empty, Colors.grey),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(color: config.$3.withOpacity(.10), borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(config.$2, size: 14, color: config.$3),
        const SizedBox(width: 4),
        Text(config.$1, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: config.$3, fontWeight: FontWeight.w700)),
      ]),
    );
  }
}

class EvidenceButton extends StatelessWidget {
  const EvidenceButton({super.key, required this.referenceIds});
  final List<String> referenceIds;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      icon: const Icon(Icons.info_outline, size: 18),
      label: const Text('Evidência'),
      onPressed: referenceIds.isEmpty ? null : () => showEvidenceSheet(context, referenceIds),
    );
  }
}

Future<void> showEvidenceSheet(BuildContext context, List<String> ids) {
  final refs = ids.map(EvidenceCatalog.byId).toList();
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: SingleChildScrollView(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Evidência', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            for (final ref in refs) ...[
              Text(ref.title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 5),
              Text('${ref.authors} • ${ref.source} • ${ref.year}'),
              if (ref.population != null) Text('População: ${ref.population}'),
              if (ref.notes != null) Text('Observações: ${ref.notes}'),
              if (ref.doi != null) Text('DOI: ${ref.doi}'),
              if (ref.pmid != null) Text('PMID: ${ref.pmid}'),
              const SizedBox(height: 16),
            ],
            OutlinedButton.icon(
              onPressed: () {
                final rootContext = Navigator.of(context).context;
                Navigator.pop(context);
                Future<void>.delayed(
                  Duration.zero,
                  () {
                    if (rootContext.mounted) showReferencesSheet(rootContext);
                  },
                );
              },
              icon: const Icon(Icons.library_books_outlined),
              label: const Text('Todas as referências'),
            ),
          ]),
        ),
      ),
    ),
  );
}

Future<void> showPatientSheet(BuildContext context) => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) => FractionallySizedBox(
        heightFactor: .94,
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 8, 4),
            child: Row(children: [
              Expanded(
                child: Text(
                  'Paciente',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              IconButton(
                tooltip: 'Fechar',
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ]),
          ),
          const Expanded(child: PatientScreen(embedded: true)),
        ]),
      ),
    );

Future<void> showReferencesSheet(BuildContext context) => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) => FractionallySizedBox(
        heightFactor: .94,
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 8, 4),
            child: Row(children: [
              Expanded(
                child: Text(
                  'Referências',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              IconButton(
                tooltip: 'Fechar',
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ]),
          ),
          const Expanded(child: ReferencesScreen(embedded: true)),
        ]),
      ),
    );

class ResponsiveBody extends StatelessWidget {
  const ResponsiveBody({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 28),
      children: [Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 760), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children)))],
    );
  }
}
