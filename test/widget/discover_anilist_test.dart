import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:myanime/features/discover/presentation/pages/discover_page.dart';
import 'package:myanime/shared/providers/repositories.dart';

import '../helpers/fakes.dart';

void main() {
  testWidgets('Discover search surfaces AniList results for a query',
      (tester) async {
    final fakeRepository = FakeAniListRepository(results: fakeAnimeResults);
    final fakeLibraryRepo = FakeLibraryRepository([]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          animeRepositoryProvider.overrideWithValue(fakeRepository),
          libraryRepositoryProvider.overrideWithValue(fakeLibraryRepo),
        ],
        child: const MaterialApp(
          home: DiscoverPage(),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const Key('discover_search_field')));
    await tester.enterText(
      find.byKey(const Key('discover_search_field')),
      'nar',
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('discover_results_state')), findsOneWidget);
    expect(find.text('Naruto'), findsWidgets);
    expect(find.text('Demon Slayer'), findsNothing);
  });

  testWidgets('Discover allows adding an AniList result to the local list',
      (tester) async {
    final fakeRepository = FakeAniListRepository(results: fakeAnimeResults);
    final fakeLibraryRepo = FakeLibraryRepository([]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          animeRepositoryProvider.overrideWithValue(fakeRepository),
          libraryRepositoryProvider.overrideWithValue(fakeLibraryRepo),
        ],
        child: const MaterialApp(
          home: DiscoverPage(),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const Key('discover_search_field')));
    await tester.enterText(
      find.byKey(const Key('discover_search_field')),
      'nar',
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    final addButton = find.text('Ajouter').first;
    expect(find.text('Ajouter'), findsAtLeastNWidgets(1));

    await tester.tap(addButton);
    await tester.pumpAndSettle();

    expect(find.text('Retirer'), findsWidgets);
    expect(fakeLibraryRepo.items.map((anime) => anime.id), contains('20'));
  });
}
