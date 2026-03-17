import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:myanime/app/app.dart';
import 'package:myanime/shared/providers/repositories.dart';
import '../helpers/fakes.dart';

void main() {
  testWidgets('shows the shell with bottom navigation and discover entry point',
      (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          animeRepositoryProvider
              .overrideWithValue(const FakeAniListRepository()),
        ],
        child: const MyAnimeApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Liste'), findsOneWidget);
    expect(find.text('Découvrir'), findsAtLeastNWidgets(1));
    expect(find.text('News'), findsOneWidget);
    expect(find.byKey(const Key('discover_results_state')), findsOneWidget);
  });
}
