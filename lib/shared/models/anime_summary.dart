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
  });

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
    );
  }

  final String id;
  final String title;
  final String subtitle;
  final String description;
  final List<String> tags;
  final int episodeCount;
  final String scoreLabel;
  final String coverImageUrl;
  final String studio;
  final int averageScore;
  final String siteUrl;

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
    };
  }
}
