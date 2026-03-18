import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:myanime/app/app.dart';
import 'package:myanime/shared/providers/repositories.dart';
import '../helpers/fakes.dart';

void main() {
  testWidgets('navigates from discover results to anime details',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final fakeLibraryRepository = FakeLibraryRepository([]);
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          animeRepositoryProvider
              .overrideWithValue(const FakeAniListRepository()),
          libraryRepositoryProvider.overrideWithValue(fakeLibraryRepository),
        ],
        child: const MyAnimeApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
        find.byKey(const Key('discover_search_field')), 'Nar');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Naruto').first);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('anime_details_page')), findsOneWidget);
    expect(find.text('Suivre cet anime'), findsOneWidget);

    await tester.tap(find.text('Suivre cet anime'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('episode_progress_field')),
      '12',
    );
    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();

    expect(find.text('Mettre à jour'), findsOneWidget);
    expect(find.text('12/220 ep'), findsOneWidget);
    expect(fakeLibraryRepository.items.first.currentEpisode, 12);
  });
}
