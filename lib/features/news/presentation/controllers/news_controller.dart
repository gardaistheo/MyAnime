import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/anime_summary.dart';
import '../../../../shared/providers/repositories.dart';

final newsControllerProvider =
    AsyncNotifierProvider<NewsController, List<AnimeSummary>>(
  NewsController.new,
);

class NewsController extends AsyncNotifier<List<AnimeSummary>> {
  @override
  Future<List<AnimeSummary>> build() {
    return ref.read(animeRepositoryProvider).fetchAiringAnime();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(animeRepositoryProvider).fetchAiringAnime(),
    );
  }
}
