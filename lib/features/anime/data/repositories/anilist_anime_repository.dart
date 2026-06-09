import '../../../../shared/models/anime_details.dart';
import '../../../../shared/models/anime_summary.dart';
import '../services/anilist_graphql_client.dart';
import 'anime_repository.dart';

/// Implémentation de [AnimeRepository] s'appuyant sur l'API GraphQL AniList.
///
/// Toutes les requêtes passent par [AniListGraphqlClient]. Les données brutes
/// sont normalisées en [AnimeSummary] ou [AnimeDetails] via des méthodes
/// privées utilitaires.
///
/// AniList est une API publique gratuite : aucune clé n'est requise.
class AniListAnimeRepository implements AnimeRepository {
  AniListAnimeRepository(this._client);

  final AniListGraphqlClient _client;

  /// Champs GraphQL communs à toutes les requêtes de liste.
  static const _summaryFields = '''
    id
    episodes
    averageScore
    description(asHtml: false)
    genres
    siteUrl
    title {
      romaji
      english
      native
    }
    coverImage {
      large
    }
    studios(isMain: true) {
      nodes {
        name
      }
    }
  ''';

  @override
  Future<List<AnimeSummary>> fetchTrendingAnime() async {
    final data = await _client.query(
      '''
      query {
        Page(page: 1, perPage: 12) {
          media(type: ANIME, sort: [TRENDING_DESC, POPULARITY_DESC]) {
            $_summaryFields
          }
        }
      }
      ''',
    );

    return _extractSummaries(data);
  }

  @override
  Future<List<AnimeSummary>> fetchAiringAnime() async {
    final data = await _client.query(
      '''
      query {
        Page(page: 1, perPage: 20) {
          media(type: ANIME, status: RELEASING, sort: [TRENDING_DESC]) {
            $_summaryFields
          }
        }
      }
      ''',
    );

    return _extractSummaries(data);
  }

  @override
  Future<AnimeDetails> getAnimeDetails(String id) async {
    final data = await _client.query(
      '''
      query (\$id: Int) {
        Media(id: \$id, type: ANIME) {
          id
          episodes
          averageScore
          description(asHtml: false)
          siteUrl
          genres
          title {
            romaji
            english
            native
          }
          coverImage {
            large
          }
          bannerImage
          studios(isMain: true) {
            nodes {
              name
            }
          }
        }
      }
      ''',
      variables: {'id': int.tryParse(id)},
    );

    final media = data['Media'] as Map<String, dynamic>;
    final title = _pickTitle(media['title'] as Map<String, dynamic>);
    final studio = _pickStudio(media['studios'] as Map<String, dynamic>);
    final episodes = media['episodes'] as int?;
    final averageScore = media['averageScore'] as int?;
    final genres =
        ((media['genres'] as List<dynamic>?) ?? const []).cast<String>();

    return AnimeDetails(
      id: (media['id'] as int).toString(),
      title: title,
      studio: studio,
      description: _sanitizeDescription(media['description'] as String?),
      episodeCount: episodes ?? 0,
      averageScore: averageScore ?? 0,
      siteUrl: media['siteUrl'] as String? ?? '',
      scoreLabel: averageScore == null ? 'Score ?' : '$averageScore/100',
      // Préférer la bannière pour l'affichage en plein écran, sinon la cover.
      coverImageUrl: media['bannerImage'] as String? ??
          (media['coverImage'] as Map<String, dynamic>)['large'] as String? ??
          '',
      genres: genres,
    );
  }

  @override
  Future<List<AnimeSummary>> searchAnime(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return fetchTrendingAnime();
    }

    final data = await _client.query(
      '''
      query (\$search: String) {
        Page(page: 1, perPage: 12) {
          media(search: \$search, type: ANIME, sort: [SEARCH_MATCH, POPULARITY_DESC]) {
            $_summaryFields
          }
        }
      }
      ''',
      variables: {'search': trimmed},
    );

    return _extractSummaries(data);
  }

  /// Transforme le champ `Page.media` d'une réponse AniList en liste de [AnimeSummary].
  List<AnimeSummary> _extractSummaries(Map<String, dynamic> data) {
    final page = data['Page'] as Map<String, dynamic>;
    final media = (page['media'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>();

    return media.map((item) {
      final titleMap = item['title'] as Map<String, dynamic>;
      final studio = _pickStudio(item['studios'] as Map<String, dynamic>);
      final averageScore = item['averageScore'] as int? ?? 0;
      final episodes = item['episodes'] as int? ?? 0;

      return AnimeSummary(
        id: (item['id'] as int).toString(),
        title: _pickTitle(titleMap),
        subtitle:
            '${studio.isEmpty ? 'Studio inconnu' : studio} • ${episodes > 0 ? '$episodes ep' : 'Épisodes ?'}',
        description: _sanitizeDescription(item['description'] as String?),
        tags: ((item['genres'] as List<dynamic>? ?? const [])).cast<String>(),
        episodeCount: episodes,
        scoreLabel: averageScore > 0 ? '$averageScore/100' : 'Score ?',
        coverImageUrl:
            (item['coverImage'] as Map<String, dynamic>)['large'] as String? ??
                '',
        studio: studio,
        averageScore: averageScore,
        siteUrl: item['siteUrl'] as String? ?? '',
      );
    }).toList();
  }

  /// Extrait le nom du studio principal depuis le nœud `studios`.
  static String _pickStudio(Map<String, dynamic> studios) {
    final nodes = (studios['nodes'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .toList();
    if (nodes.isEmpty) {
      return 'Studio inconnu';
    }
    return nodes.first['name'] as String? ?? 'Studio inconnu';
  }

  /// Sélectionne le titre en anglais, puis en romaji, puis en natif.
  static String _pickTitle(Map<String, dynamic> titleMap) {
    return titleMap['english'] as String? ??
        titleMap['romaji'] as String? ??
        titleMap['native'] as String? ??
        'Anime inconnu';
  }

  /// Supprime les balises HTML et décode les entités HTML du synopsis AniList.
  static String _sanitizeDescription(String? input) {
    if (input == null || input.isEmpty) {
      return 'Pas de description disponible.';
    }

    return input
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<[^>]+>'), '')
        .replaceAll('&quot;', '"')
        .replaceAll('&#039;', "'")
        .replaceAll('&amp;', '&')
        .trim();
  }
}
