import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/anime/data/repositories/anilist_anime_repository.dart';
import '../../features/anime/data/repositories/anime_repository.dart';
import '../../features/anime/data/services/anilist_graphql_client.dart';
import '../../features/library/data/repositories/library_repository.dart';
import '../../features/library/data/repositories/local_library_repository.dart';
import '../models/anime_details.dart';

final animeHttpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

final aniListGraphqlClientProvider = Provider<AniListGraphqlClient>((ref) {
  return AniListGraphqlClient(ref.watch(animeHttpClientProvider));
});

final animeRepositoryProvider = Provider<AnimeRepository>((ref) {
  return AniListAnimeRepository(ref.watch(aniListGraphqlClientProvider));
});

final sharedPreferencesAsyncProvider = Provider<SharedPreferencesAsync>((ref) {
  return SharedPreferencesAsync();
});

final libraryRepositoryProvider = Provider<LibraryRepository>((ref) {
  return LocalLibraryRepository(ref.watch(sharedPreferencesAsyncProvider));
});

final animeDetailsProvider =
    FutureProvider.family<AnimeDetails, String>((ref, id) {
  return ref.read(animeRepositoryProvider).getAnimeDetails(id);
});
