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
}
