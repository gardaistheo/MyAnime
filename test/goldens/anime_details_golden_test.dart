import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:myanime/features/anime_details/presentation/pages/anime_details_page.dart';
import 'package:myanime/shared/providers/repositories.dart';

import '../helpers/fakes.dart';

void main() {
  testWidgets('anime details golden', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          animeRepositoryProvider
              .overrideWithValue(const FakeAniListRepository()),
        ],
        child: const MaterialApp(
          themeMode: ThemeMode.dark,
          home: AnimeDetailsPage(animeId: '20'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('anime_details.png'),
    );
  });
}
