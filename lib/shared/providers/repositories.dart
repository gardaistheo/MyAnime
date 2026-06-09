import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/anime/data/repositories/anilist_anime_repository.dart';
import '../../features/anime/data/repositories/anime_repository.dart';
import '../../features/anime/data/services/anilist_graphql_client.dart';
import '../../features/library/data/repositories/library_repository.dart';
import '../../features/library/data/repositories/local_library_repository.dart';
import '../../features/profile/data/repositories/profile_repository.dart';
import '../models/anime_details.dart';

/// Client HTTP partagé par toutes les requêtes de l'application.
///
/// Utilise [ref.onDispose] pour fermer proprement la connexion quand le
/// provider est détruit (ex. lors des tests).
final animeHttpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

/// Client GraphQL AniList injecté dans [AniListAnimeRepository].
final aniListGraphqlClientProvider = Provider<AniListGraphqlClient>((ref) {
  return AniListGraphqlClient(ref.watch(animeHttpClientProvider));
});

/// Dépôt d'accès aux données anime (implémentation AniList).
///
/// Injecter ce provider dans les controllers plutôt que d'instancier
/// [AniListAnimeRepository] directement, afin de permettre le remplacement
/// par un faux dépôt dans les tests.
final animeRepositoryProvider = Provider<AnimeRepository>((ref) {
  return AniListAnimeRepository(ref.watch(aniListGraphqlClientProvider));
});

/// Instance partagée de SharedPreferences (API asynchrone).
///
/// Exposé comme provider pour permettre l'injection d'une implémentation
/// en mémoire ([InMemorySharedPreferencesAsync]) dans les tests unitaires.
final sharedPreferencesAsyncProvider = Provider<SharedPreferencesAsync>((ref) {
  return SharedPreferencesAsync();
});

/// Dépôt de persistance de la bibliothèque utilisateur.
final libraryRepositoryProvider = Provider<LibraryRepository>((ref) {
  return LocalLibraryRepository(ref.watch(sharedPreferencesAsyncProvider));
});

/// Dépôt de persistance du profil utilisateur.
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(ref.watch(sharedPreferencesAsyncProvider));
});

/// Provider dérivé qui charge la fiche détaillée d'un anime par son [id] AniList.
///
/// Le résultat est mis en cache par Riverpod tant que le provider est écouté.
/// Utiliser `ref.invalidate(animeDetailsProvider(id))` pour forcer un rechargement.
final animeDetailsProvider =
    FutureProvider.family<AnimeDetails, String>((ref, id) {
  return ref.read(animeRepositoryProvider).getAnimeDetails(id);
});
