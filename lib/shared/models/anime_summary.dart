class AnimeSummary {
  const AnimeSummary({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.tags,
    required this.episodeCount,
    required this.scoreLabel,
  });

  final String id;
  final String title;
  final String subtitle;
  final String description;
  final List<String> tags;
  final int episodeCount;
  final String scoreLabel;
}
