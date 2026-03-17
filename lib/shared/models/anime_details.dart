class AnimeDetails {
  const AnimeDetails({
    required this.id,
    required this.title,
    required this.studio,
    required this.description,
    required this.episodeCount,
    required this.averageScore,
    required this.siteUrl,
    required this.trailerLabel,
    required this.recommendationLabel,
    required this.characterLabel,
    required this.episodeProgressLabel,
    required this.scoreLabel,
    required this.coverImageUrl,
  });

  final String id;
  final String title;
  final String studio;
  final String description;
  final int episodeCount;
  final int averageScore;
  final String siteUrl;
  final String trailerLabel;
  final String recommendationLabel;
  final String characterLabel;
  final String episodeProgressLabel;
  final String scoreLabel;
  final String coverImageUrl;
}
