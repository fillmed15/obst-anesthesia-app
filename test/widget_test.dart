import 'package:flutter/widgets.dart' show Size;
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

  for (final viewport in <String, Size>{
    'iPhone 13 mini': const Size(375, 812),
    'Galaxy S': const Size(360, 800),
    'tablet': const Size(768, 1024),
  }.entries) {
    testWidgets('home não apresenta overflow em ${viewport.key}', (
      tester,
    ) async {
      tester.view.physicalSize = viewport.value;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        AppScope(notifier: AppState(), child: const ObstetricApp()),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('RAQUIANESTESIA'), findsOneWidget);
      expect(find.text('EMERGÊNCIAS'), findsOneWidget);
    });
  }
}
