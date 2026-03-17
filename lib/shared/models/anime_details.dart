class AnimeDetails {
  const AnimeDetails({
    required this.id,
    required this.title,
    required this.studio,
    required this.description,
    required this.trailerLabel,
    required this.recommendationLabel,
    required this.characterLabel,
    required this.episodeProgressLabel,
    required this.scoreLabel,
  });

  final String id;
  final String title;
  final String studio;
  final String description;
  final String trailerLabel;
  final String recommendationLabel;
  final String characterLabel;
  final String episodeProgressLabel;
  final String scoreLabel;
}
