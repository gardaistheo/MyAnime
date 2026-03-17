import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_app.dart';

void main() {
  testWidgets('shows the shell with bottom navigation and discover entry point',
      (
    tester,
  ) async {
    await pumpMyAnimeApp(tester);

    expect(find.text('Liste'), findsOneWidget);
    expect(find.text('Découvrir'), findsAtLeastNWidgets(1));
    expect(find.text('News'), findsOneWidget);
    expect(find.byKey(const Key('discover_placeholder_state')), findsOneWidget);
  });
}
