class TraceMoeResult {
  const TraceMoeResult({
    required this.anilistId,
    required this.title,
    required this.episode,
    required this.similarity,
    required this.from,
    required this.to,
    required this.at,
    required this.previewImageUrl,
    required this.previewVideoUrl,
    required this.filename,
    required this.isAdult,
  });

  factory TraceMoeResult.fromJson(Map<String, dynamic> json) {
    final anilist = json['anilist'];
    final anilistMap = anilist is Map<String, dynamic> ? anilist : null;
    final titleMap = anilistMap?['title'] as Map<String, dynamic>?;

    String? pickTitle() {
      final english = titleMap?['english'] as String?;
      final romaji = titleMap?['romaji'] as String?;
      final native = titleMap?['native'] as String?;
      return english ?? romaji ?? native;
    }

    return TraceMoeResult(
      anilistId: _parseInt(anilistMap?['id']) ?? _parseInt(anilist) ?? 0,
      title: pickTitle() ?? _filenameToTitle(json['filename'] as String?),
      episode: _parseInt(json['episode']),
      similarity: (json['similarity'] as num?)?.toDouble() ?? 0,
      from: (json['from'] as num?)?.toDouble() ?? 0,
      to: (json['to'] as num?)?.toDouble() ?? 0,
      at: (json['at'] as num?)?.toDouble() ?? 0,
      previewImageUrl: json['image'] as String? ?? '',
      previewVideoUrl: json['video'] as String? ?? '',
      filename: json['filename'] as String? ?? 'Unknown',
      isAdult: anilistMap?['isAdult'] as bool? ?? false,
    );
  }

  final int anilistId;
  final String title;
  final int? episode;
  final double similarity;
  final double from;
  final double to;
  final double at;
  final String previewImageUrl;
  final String previewVideoUrl;
  final String filename;
  final bool isAdult;

  String get confidenceLabel {
    if (similarity >= 0.95) {
      return 'Très forte';
    }
    if (similarity >= 0.8) {
      return 'Forte';
    }
    if (similarity >= 0.65) {
      return 'Moyenne';
    }
    return 'Faible';
  }

  bool get isLikelyMatch => similarity >= 0.8;

  String get similarityPercent => '${(similarity * 100).toStringAsFixed(1)}%';

  String get episodeLabel =>
      episode == null ? 'Épisode inconnu' : 'Épisode $episode';

  String get timestampLabel => _formatTimestamp(at);

  String get rangeLabel =>
      '${_formatTimestamp(from)} - ${_formatTimestamp(to)}';

  static String _filenameToTitle(String? filename) {
    if (filename == null || filename.isEmpty) {
      return 'Anime inconnu';
    }
    return filename.split(' - ').first;
  }

  static String _formatTimestamp(double seconds) {
    final duration = Duration(milliseconds: (seconds * 1000).round());
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final secs = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '${duration.inHours > 0 ? '${duration.inHours.toString().padLeft(2, '0')}:' : ''}$minutes:$secs';
  }

  static int? _parseInt(Object? value) {
    if (value == null) {
      return null;
    }
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.round();
    }
    if (value is String) {
      return int.tryParse(value) ?? double.tryParse(value)?.round();
    }
    return null;
  }
}
