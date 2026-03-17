import '../../../../shared/models/anime_details.dart';
import '../../../../shared/models/anime_summary.dart';

abstract class AnimeRepository {
  Future<List<AnimeSummary>> fetchTrendingAnime();

  Future<List<AnimeSummary>> searchAnime(String query);

  Future<AnimeDetails> getAnimeDetails(String id);
}
