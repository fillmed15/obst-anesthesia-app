import 'package:flutter/material.dart';

import '../services/app_state.dart';
import '../theme/app_theme.dart';
import 'emergencies_screen.dart';
import 'labor_analgesia_screen.dart';
import 'patient_screen.dart';
import 'references_screen.dart';
import 'risk_safety_screen.dart';
import 'spinal_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final patient = AppScope.of(context).patient;
    return Scaffold(
      appBar: AppBar(
        title: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Obst Anesthesia'),
          Text('decisão rápida • evidência rastreável', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ]),
        actions: [IconButton(tooltip: 'Referências', icon: const Icon(Icons.menu_book_outlined), onPressed: () => _open(context, const ReferencesScreen()))],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          children: [Center(child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => _open(context, const PatientScreen()),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFF1EAF8), Color(0xFFFFEEF3)]), borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFE2D5EC))),
                  child: Row(children: [
                    const CircleAvatar(backgroundColor: Colors.white, foregroundColor: AppColors.primary, child: Icon(Icons.person_outline)),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(patient.identifier?.isNotEmpty == true ? patient.identifier! : 'Paciente', style: const TextStyle(fontWeight: FontWeight.w800)),
                      Text(patient.compactSummary, style: Theme.of(context).textTheme.bodySmall),
                    ])),
                    const Icon(Icons.chevron_right),
                  ]),
                ),
              ),
              const SizedBox(height: 18),
              LayoutBuilder(builder: (context, constraints) {
                final cards = [
                  _ModuleCard('RAQUIANESTESIA', 'Cesárea / neuroeixo', Icons.medication_liquid_outlined, AppColors.primary, () => _open(context, const SpinalScreen())),
                  _ModuleCard('ANALGESIA DE PARTO', 'Peridural / CSE / DPE', Icons.timeline_outlined, AppColors.secondary, () => _open(context, const LaborAnalgesiaScreen())),
                  _ModuleCard('RISCO & SEGURANÇA', 'Plaquetas / anticoagulação', Icons.health_and_safety_outlined, AppColors.warning, () => _open(context, const RiskSafetyScreen())),
                  _ModuleCard('EMERGÊNCIAS', 'Protocolos QRH', Icons.emergency_outlined, AppColors.danger, () => _open(context, const EmergenciesScreen())),
                ];
                if (constraints.maxWidth < 620) return Column(children: [for (final card in cards) Padding(padding: const EdgeInsets.only(bottom: 10), child: card)]);
                return GridView.count(crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.7, children: cards);
              }),
              const SizedBox(height: 20),
              Text('Ferramenta de apoio à decisão clínica destinada a profissionais de saúde. Não substitui julgamento clínico, protocolos institucionais ou avaliação individual da paciente.', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ]),
          ))],
        ),
      ),
    );
  }

  static void _open(BuildContext context, Widget screen) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
}

class _ModuleCard extends StatelessWidget {
  const _ModuleCard(this.title, this.subtitle, this.icon, this.color, this.onTap);
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(children: [
            Container(width: 52, height: 52, decoration: BoxDecoration(color: color.withOpacity(.12), borderRadius: BorderRadius.circular(16)), child: Icon(icon, color: color, size: 28)),
            const SizedBox(width: 14),
            Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800, letterSpacing: .2)),
              const SizedBox(height: 4),
              Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
            ])),
            Icon(Icons.chevron_right, color: color),
          ]),
        ),
      ),
    );
  }
}
