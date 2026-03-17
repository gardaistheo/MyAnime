import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_app.dart';

void main() {
  testWidgets(
      'discover transitions from placeholder to idle to loading to results', (
    tester,
  ) async {
    await pumpMyAnimeApp(tester);

    expect(find.byKey(const Key('discover_placeholder_state')), findsOneWidget);

    await tester.tap(find.byKey(const Key('discover_search_field')));
    await tester.pump();
    expect(find.byKey(const Key('discover_empty_state')), findsOneWidget);

    await tester.enterText(
        find.byKey(const Key('discover_search_field')), 'Nar');
    await tester.pump();
    expect(find.byKey(const Key('discover_loading_state')), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('discover_results_state')), findsOneWidget);
    expect(find.text('Naruto'), findsOneWidget);
  });
}
