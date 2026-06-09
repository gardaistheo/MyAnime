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

  final String id;
  final String title;
  final String studio;
  final String description;
  final int episodeCount;
  final int averageScore;
  final String siteUrl;
  final String scoreLabel;
  final String coverImageUrl;
  final List<String> genres;
}
