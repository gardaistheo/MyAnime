import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/anime/data/repositories/anime_repository.dart';
import '../../features/anime/data/repositories/mock_anime_repository.dart';
import '../models/anime_details.dart';

final animeRepositoryProvider = Provider<AnimeRepository>((ref) {
  return const MockAnimeRepository();
});

final animeDetailsProvider =
    FutureProvider.family<AnimeDetails, String>((ref, id) {
  return ref.read(animeRepositoryProvider).getAnimeDetails(id);
});
