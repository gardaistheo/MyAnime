import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/anime_summary.dart';
import '../../../../shared/providers/repositories.dart';

final libraryControllerProvider =
    AsyncNotifierProvider<LibraryController, List<AnimeSummary>>(
  LibraryController.new,
);

final libraryMembershipProvider = Provider.family<bool, String>((ref, animeId) {
  final library =
      ref.watch(libraryControllerProvider).asData?.value ?? const [];
  return library.any((anime) => anime.id == animeId);
});

final libraryAnimeProvider =
    Provider.family<AnimeSummary?, String>((ref, animeId) {
  final library =
      ref.watch(libraryControllerProvider).asData?.value ?? const [];
  for (final anime in library) {
    if (anime.id == animeId) {
      return anime;
    }
  }
  return null;
});

class LibraryController extends AsyncNotifier<List<AnimeSummary>> {
  @override
  Future<List<AnimeSummary>> build() {
    return ref.read(libraryRepositoryProvider).loadLibrary();
  }

  Future<void> toggleAnime(AnimeSummary anime) async {
    final current = state.asData?.value ?? const [];
    final exists = current.any((item) => item.id == anime.id);

    final next = exists
        ? current.where((item) => item.id != anime.id).toList()
        : [...current, anime];

    state = AsyncData(next);
    await ref.read(libraryRepositoryProvider).saveLibrary(next);
  }

  Future<void> saveProgress(AnimeSummary anime, int currentEpisode) async {
    final current = state.asData?.value ?? const [];
    final clampedEpisode = anime.episodeCount > 0
        ? currentEpisode.clamp(0, anime.episodeCount)
        : currentEpisode.clamp(0, 9999);
    final updatedAnime = anime.copyWith(currentEpisode: clampedEpisode);
    final index = current.indexWhere((item) => item.id == anime.id);

    final next = [...current];
    if (index >= 0) {
      next[index] = updatedAnime;
    } else {
      next.add(updatedAnime);
    }

    state = AsyncData(next);
    await ref.read(libraryRepositoryProvider).saveLibrary(next);
  }
}
