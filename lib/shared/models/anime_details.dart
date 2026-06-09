/// Fiche détaillée d'un anime, chargée à la demande depuis l'API AniList.
///
/// Contrairement à [AnimeSummary], [AnimeDetails] n'est pas persisté localement :
/// il est obtenu via [AnimeRepository.getAnimeDetails] et mis en cache par
/// le [FutureProvider.family] `animeDetailsProvider`.
class AnimeDetails {
  const AnimeDetails({
    required this.id,
    required this.title,
    required this.studio,
    required this.description,
    required this.episodeCount,
    required this.averageScore,
    required this.siteUrl,
    required this.scoreLabel,
    required this.coverImageUrl,
    this.genres = const [],
  });

  /// Identifiant unique AniList.
  final String id;

  /// Titre principal de l'anime (anglais en priorité, sinon romaji, sinon natif).
  final String title;

  /// Nom du studio de production principal.
  final String studio;

  /// Synopsis nettoyé (sans HTML), ou `"Pas de description disponible."`.
  final String description;

  /// Nombre total d'épisodes. Vaut `0` si inconnu (série en cours).
  final int episodeCount;

  /// Score moyen AniList sur 100. Vaut `0` si indisponible.
  final int averageScore;

  /// URL de la page officielle AniList.
  final String siteUrl;

  /// Score formaté pour l'affichage, ex. `"87/100"` ou `"Score ?"`.
  final String scoreLabel;

  /// URL de la bannière ou de la cover (grande image AniList).
  final String coverImageUrl;

  /// Liste des genres, ex. `["Action", "Adventure", "Fantasy"]`.
  final List<String> genres;
}
