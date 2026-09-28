import 'package:flutter_test/flutter_test.dart';
import 'package:obst_anesthesia_app/app.dart';
import 'package:obst_anesthesia_app/services/app_state.dart';

void main() {
  testWidgets('home exibe os quatro módulos principais', (tester) async {
    await tester.pumpWidget(
      AppScope(notifier: AppState(), child: const ObstetricApp()),
    );

    expect(find.text('RAQUIANESTESIA'), findsOneWidget);
    expect(find.text('ANALGESIA DE PARTO'), findsOneWidget);
    expect(find.text('RISCO & SEGURANÇA'), findsOneWidget);
    expect(find.text('EMERGÊNCIAS'), findsOneWidget);
  });
}
