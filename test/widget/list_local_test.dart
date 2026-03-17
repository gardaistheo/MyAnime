import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:myanime/features/library/presentation/controllers/library_controller.dart';
import 'package:myanime/shared/providers/repositories.dart';

import '../helpers/fakes.dart';

void main() {
  final firstAnime = fakeAnimeResults[0];
  final secondAnime = fakeAnimeResults[1];

  test('Library controller toggles anime and keeps local list in sync',
      () async {
    final fakeRepo = FakeLibraryRepository([firstAnime]);
    final container = ProviderContainer(
      overrides: [
        libraryRepositoryProvider.overrideWithValue(fakeRepo),
      ],
    );
    addTearDown(container.dispose);

    final controller = container.read(libraryControllerProvider.notifier);
    await container.read(libraryControllerProvider.future);

    final initial = container.read(libraryControllerProvider).asData;
    expect(initial, isNotNull);
    expect(initial!.value.map((anime) => anime.id).toSet(), {firstAnime.id});

    await controller.toggleAnime(secondAnime);
    final afterAdd = container.read(libraryControllerProvider).asData;
    expect(afterAdd, isNotNull);
    expect(
      afterAdd!.value.map((anime) => anime.id).toSet(),
      {firstAnime.id, secondAnime.id},
    );
    expect(fakeRepo.items.map((anime) => anime.id).toSet(),
        {firstAnime.id, secondAnime.id});

    await controller.toggleAnime(firstAnime);
    final afterRemove = container.read(libraryControllerProvider).asData;
    expect(afterRemove, isNotNull);
    expect(afterRemove!.value.map((anime) => anime.id), [secondAnime.id]);
    expect(fakeRepo.items.map((anime) => anime.id), [secondAnime.id]);
  });
}
