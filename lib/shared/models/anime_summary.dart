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
  final int currentEpisode;

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
