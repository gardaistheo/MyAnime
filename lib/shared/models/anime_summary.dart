/// Représentation allégée d'un anime, utilisée dans les listes (discover,
/// library, news) et pour la persistance locale.
///
/// [AnimeSummary] est immuable : toute modification passe par [copyWith].
/// La sérialisation JSON ([fromJson] / [toJson]) est utilisée par
/// [LocalLibraryRepository] pour stocker la bibliothèque de l'utilisateur.
class AnimeSummary {
  const AnimeSummary({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.tags,
    required this.episodeCount,
    required this.scoreLabel,
    required this.coverImageUrl,
    required this.studio,
    required this.averageScore,
    required this.siteUrl,
    this.currentEpisode = 0,
  });

  /// Désérialise un [AnimeSummary] depuis le JSON stocké dans SharedPreferences.
  factory AnimeSummary.fromJson(Map<String, dynamic> json) {
    return AnimeSummary(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      description: json['description'] as String,
      tags: (json['tags'] as List<dynamic>).cast<String>(),
      episodeCount: json['episodeCount'] as int,
      scoreLabel: json['scoreLabel'] as String,
      coverImageUrl: json['coverImageUrl'] as String,
      studio: json['studio'] as String,
      averageScore: json['averageScore'] as int,
      siteUrl: json['siteUrl'] as String,
      currentEpisode: json['currentEpisode'] as int? ?? 0,
    );
  }

  /// Identifiant unique AniList (ex. `"20"` pour Naruto).
  final String id;

  /// Titre principal de l'anime (anglais en priorité, sinon romaji, sinon natif).
  final String title;

  /// Ligne d'accroche affichée sous le titre, ex. `"Studio MAPPA • 24 ep"`.
  final String subtitle;

  /// Synopsis court, sans balises HTML (nettoyé par [AniListAnimeRepository]).
  final String description;

  /// Genres de l'anime, ex. `["Action", "Fantasy"]`.
  final List<String> tags;

  /// Nombre total d'épisodes. Vaut `0` si inconnu (séries en cours sans fin annoncée).
  final int episodeCount;

  /// Score moyen formaté pour l'affichage, ex. `"87/100"` ou `"Score ?"`.
  final String scoreLabel;

  /// URL de la cover (grande image AniList).
  final String coverImageUrl;

  /// Nom du studio de production principal.
  final String studio;

  /// Score moyen AniList sur 100. Vaut `0` si indisponible.
  final int averageScore;

  /// URL de la page officielle AniList de l'anime.
  final String siteUrl;

  /// Épisode actuellement suivi par l'utilisateur dans sa bibliothèque.
  /// Vaut `0` si l'anime n'est pas encore commencé.
  final int currentEpisode;

  /// Retourne une copie avec les champs surchargés fournis.
  AnimeSummary copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? description,
    List<String>? tags,
    int? episodeCount,
    String? scoreLabel,
    String? coverImageUrl,
    String? studio,
    int? averageScore,
    String? siteUrl,
    int? currentEpisode,
  }) {
    return AnimeSummary(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      episodeCount: episodeCount ?? this.episodeCount,
      scoreLabel: scoreLabel ?? this.scoreLabel,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      studio: studio ?? this.studio,
      averageScore: averageScore ?? this.averageScore,
      siteUrl: siteUrl ?? this.siteUrl,
      currentEpisode: currentEpisode ?? this.currentEpisode,
    );
  }

  /// Sérialise l'anime en JSON pour le stockage dans SharedPreferences.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'description': description,
      'tags': tags,
      'episodeCount': episodeCount,
      'scoreLabel': scoreLabel,
      'coverImageUrl': coverImageUrl,
      'studio': studio,
      'averageScore': averageScore,
      'siteUrl': siteUrl,
      'currentEpisode': currentEpisode,
    };
  }
}
