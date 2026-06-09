import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/anime_summary.dart';
import '../../../../shared/providers/repositories.dart';

/// Provider du controller News.
final newsControllerProvider =
    AsyncNotifierProvider<NewsController, List<AnimeSummary>>(
  NewsController.new,
);

/// Gestionnaire d'état de l'écran News.
///
/// Charge la liste des animes actuellement en cours de diffusion depuis AniList
/// via [AnimeRepository.fetchAiringAnime]. Expose un [refresh] pour le
/// pull-to-refresh et le bouton de rechargement manuel.
class NewsController extends AsyncNotifier<List<AnimeSummary>> {
  @override
  Future<List<AnimeSummary>> build() {
    return ref.read(animeRepositoryProvider).fetchAiringAnime();
  }

  /// Recharge la liste des animes en cours depuis l'API.
  ///
  /// Passe l'état en [AsyncLoading] pendant le chargement, puis en
  /// [AsyncData] ou [AsyncError] selon le résultat.
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(animeRepositoryProvider).fetchAiringAnime(),
    );
  }
}
