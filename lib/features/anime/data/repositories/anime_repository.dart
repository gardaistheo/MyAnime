import '../../../../shared/models/anime_details.dart';
import '../../../../shared/models/anime_summary.dart';

/// Contrat d'accès aux données anime.
///
/// Cette interface isole la couche présentation du fournisseur de données
/// concret (ex. [AniListAnimeRepository]). Elle facilite les tests unitaires
/// en permettant d'injecter un faux dépôt ([FakeAnimeRepository]).
abstract class AnimeRepository {
  /// Retourne les animes les plus tendance du moment.
  ///
  /// Utilisé par [DiscoverController] pour alimenter l'écran principal.
  Future<List<AnimeSummary>> fetchTrendingAnime();

  /// Retourne les animes actuellement en cours de diffusion.
  ///
  /// Utilisé par [NewsController] pour alimenter l'écran News.
  Future<List<AnimeSummary>> fetchAiringAnime();

  /// Recherche des animes par [query] textuelle.
  ///
  /// Si [query] est vide, délègue à [fetchTrendingAnime].
  Future<List<AnimeSummary>> searchAnime(String query);

  /// Récupère la fiche complète d'un anime par son identifiant AniList [id].
  ///
  /// Lance une exception si l'anime est introuvable ou si le réseau est indisponible.
  Future<AnimeDetails> getAnimeDetails(String id);
}
