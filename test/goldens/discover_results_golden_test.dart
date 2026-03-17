import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_app.dart';

void main() {
  testWidgets('discover results golden', (tester) async {
    await pumpMyAnimeApp(tester);

    await tester.tap(find.byKey(const Key('discover_search_field')));
    await tester.pump();
    await tester.enterText(
        find.byKey(const Key('discover_search_field')), 'Nar');
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(Scaffold).first,
      matchesGoldenFile('discover_results.png'),
    );
  });
}
