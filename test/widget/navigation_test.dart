import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_app.dart';

void main() {
  testWidgets('navigates from discover results to anime details',
      (tester) async {
    await pumpMyAnimeApp(tester);

    await tester.tap(find.byKey(const Key('discover_search_field')));
    await tester.pump();
    await tester.enterText(
        find.byKey(const Key('discover_search_field')), 'Nar');
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Naruto').first);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('anime_details_page')), findsOneWidget);
    expect(find.text('Ajouter'), findsOneWidget);
  });
}
