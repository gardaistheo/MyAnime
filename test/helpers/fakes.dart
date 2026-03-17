import 'package:myanime/features/anime/data/repositories/anime_repository.dart';
import 'package:myanime/features/library/data/repositories/library_repository.dart';
import 'package:myanime/shared/models/anime_details.dart';
import 'package:myanime/shared/models/anime_summary.dart';

const fakeAnimeResults = [
  AnimeSummary(
    id: '20',
    title: 'Naruto',
    subtitle: 'Studio Pierrot • 220 ep',
    description: 'Classic ninja shonen.',
    tags: ['Action', 'Adventure'],
    episodeCount: 220,
    scoreLabel: '80/100',
    coverImageUrl: '',
    studio: 'Studio Pierrot',
    averageScore: 80,
    siteUrl: 'https://anilist.co/anime/20',
  ),
  AnimeSummary(
    id: '1735',
    title: 'Naruto: Shippuuden',
    subtitle: 'Studio Pierrot • 500 ep',
    description: 'More ninja drama.',
    tags: ['Action', 'Adventure'],
    episodeCount: 500,
    scoreLabel: '83/100',
    coverImageUrl: '',
    studio: 'Studio Pierrot',
    averageScore: 83,
    siteUrl: 'https://anilist.co/anime/1735',
  ),
  AnimeSummary(
    id: '101922',
    title: 'Demon Slayer',
    subtitle: 'ufotable • 26 ep',
    description: 'Slay demons and be cool.',
    tags: ['Action', 'Drama'],
    episodeCount: 26,
    scoreLabel: '84/100',
    coverImageUrl: '',
    studio: 'ufotable',
    averageScore: 84,
    siteUrl: 'https://anilist.co/anime/101922',
  ),
];

class FakeAniListRepository implements AnimeRepository {
  const FakeAniListRepository({
    this.results = fakeAnimeResults,
  });

  final List<AnimeSummary> results;

  @override
  Future<List<AnimeSummary>> fetchTrendingAnime() async => results;

  @override
  Future<AnimeDetails> getAnimeDetails(String id) async {
    final anime = results.firstWhere((item) => item.id == id);
    return AnimeDetails(
      id: anime.id,
      title: anime.title,
      studio: anime.studio,
      description: anime.description,
      episodeCount: anime.episodeCount,
      averageScore: anime.averageScore,
      siteUrl: anime.siteUrl,
      trailerLabel: 'Voir sur AniList',
      recommendationLabel: 'Recommandations à venir',
      characterLabel: 'Personnages à venir',
      episodeProgressLabel:
          anime.episodeCount > 0 ? '0/${anime.episodeCount} ep' : 'Épisodes ?',
      scoreLabel: anime.scoreLabel,
      coverImageUrl: anime.coverImageUrl,
    );
  }

  @override
  Future<List<AnimeSummary>> searchAnime(String query) async {
    final normalized = query.toLowerCase();
    return results
        .where((anime) => anime.title.toLowerCase().contains(normalized))
        .toList();
  }
}

class FakeLibraryRepository implements LibraryRepository {
  FakeLibraryRepository(this.items);

  List<AnimeSummary> items;

  @override
  Future<List<AnimeSummary>> loadLibrary() async => items;

  @override
  Future<void> saveLibrary(List<AnimeSummary> anime) async {
    items = anime;
  }
}
