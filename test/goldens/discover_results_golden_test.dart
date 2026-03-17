import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:myanime/app/app.dart';
import 'package:myanime/shared/providers/repositories.dart';
import '../helpers/fakes.dart';

void main() {
  testWidgets('discover results golden', (tester) async {
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

    await tester.enterText(
        find.byKey(const Key('discover_search_field')), 'Nar');
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(Scaffold).first,
      matchesGoldenFile('discover_results.png'),
    );
  });
}
