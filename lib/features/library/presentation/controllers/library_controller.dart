import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/anime_summary.dart';
import '../../../../shared/providers/repositories.dart';

/// Provider principal de la bibliothèque utilisateur.
///
/// Expose la liste complète des [AnimeSummary] sauvegardés. Les widgets
/// doivent utiliser [libraryAnimeProvider] ou [libraryMembershipProvider]
/// pour des lookups ciblés, afin d'éviter des rebuilds inutiles.
final libraryControllerProvider =
    AsyncNotifierProvider<LibraryController, List<AnimeSummary>>(
  LibraryController.new,
);

/// Retourne `true` si l'anime identifié par [animeId] est dans la bibliothèque.
///
/// Ce provider dérivé évite à ses consommateurs de se rebâtir quand un
/// autre anime de la liste change.
final libraryMembershipProvider = Provider.family<bool, String>((ref, animeId) {
  final library =
      ref.watch(libraryControllerProvider).asData?.value ?? const [];
  return library.any((anime) => anime.id == animeId);
});

/// Retourne l'[AnimeSummary] correspondant à [animeId], ou `null` si absent.
///
/// Utilisé par [AnimeDetailsPage] pour lire la progression de l'utilisateur
/// sur un anime spécifique sans écouter toute la bibliothèque.
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

/// Gestionnaire d'état de la bibliothèque utilisateur.
///
/// Charge la bibliothèque depuis [LibraryRepository] au démarrage, puis
/// maintient la liste en mémoire de façon optimiste : l'état Riverpod est
/// mis à jour immédiatement avant que la persistance soit confirmée.
class LibraryController extends AsyncNotifier<List<AnimeSummary>> {
  @override
  Future<List<AnimeSummary>> build() {
    return ref.read(libraryRepositoryProvider).loadLibrary();
  }

  /// Ajoute [anime] à la bibliothèque s'il est absent, le retire sinon.
  Future<void> toggleAnime(AnimeSummary anime) async {
    final current = state.asData?.value ?? const [];
    final exists = current.any((item) => item.id == anime.id);

    final next = exists
        ? current.where((item) => item.id != anime.id).toList()
        : [...current, anime];

    state = AsyncData(next);
    await ref.read(libraryRepositoryProvider).saveLibrary(next);
  }

  /// Met à jour la progression de [anime] à [currentEpisode] épisodes vus.
  ///
  /// Si [anime] n'est pas encore dans la bibliothèque, il y est ajouté.
  /// L'épisode est borné entre `0` et [AnimeSummary.episodeCount] (si connu).
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
