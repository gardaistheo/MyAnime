import '../../../../shared/models/anime_details.dart';
import '../../../../shared/models/anime_summary.dart';
import 'anime_repository.dart';

class MockAnimeRepository implements AnimeRepository {
  const MockAnimeRepository();

  static const _anime = [
    AnimeSummary(
      id: 'naruto',
      title: 'Naruto',
      subtitle: 'Plateforme. Nombre episodes. Ratio Like/Dislike',
      description:
          'Un classique shonen avec des ninjas, des rivalites, des arcs interminables et assez de matiere pour remplir la carte de resultat du design.',
      tags: ['Shonen', 'Ninja', 'Aventure'],
      episodeCount: 140,
      scoreLabel: 'Score',
    ),
    AnimeSummary(
      id: 'nana',
      title: 'Nana',
      subtitle: 'Plateforme. Nombre episodes. Ratio Like/Dislike',
      description:
          'Deux vies qui se croisent a Tokyo. Plus pose, plus drama, utile pour remplir la liste de resultats et varier le ton.',
      tags: ['Drama', 'Musique', 'Josei'],
      episodeCount: 47,
      scoreLabel: 'Score',
    ),
    AnimeSummary(
      id: 'noragami',
      title: 'Noragami',
      subtitle: 'Plateforme. Nombre episodes. Ratio Like/Dislike',
      description:
          'Un dieu fauche qui cherche de la reconnaissance. Format parfait pour alimenter un faux resultat de recherche.',
      tags: ['Action', 'Supernaturel', 'Comedie'],
      episodeCount: 25,
      scoreLabel: 'Score',
    ),
    AnimeSummary(
      id: 'neon-genesis-evangelion',
      title: 'Neon Genesis Evangelion',
      subtitle: 'Plateforme. Nombre episodes. Ratio Like/Dislike',
      description:
          'Parce qu’un moteur de recherche anime sans Evangelion, ca ressemble vite a un faux produit.',
      tags: ['Mecha', 'Psychologique', 'Science-fiction'],
      episodeCount: 26,
      scoreLabel: 'Score',
    ),
  ];

  @override
  Future<List<AnimeSummary>> searchAnime(String query) async {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) {
      return const [];
    }

    final matches = _anime.where((anime) {
      final haystack = '${anime.title} ${anime.description}'.toLowerCase();
      return haystack.contains(normalized);
    }).toList();

    if (matches.isNotEmpty) {
      return matches;
    }

    return _anime;
  }

  @override
  Future<AnimeDetails> getAnimeDetails(String id) async {
    final summary = _anime.firstWhere(
      (anime) => anime.id == id,
      orElse: () => _anime.first,
    );

    return AnimeDetails(
      id: summary.id,
      title: summary.title,
      studio: 'Studio',
      description:
          'Cette fiche reste volontairement approximative: il manque encore le vrai contenu Figma et les vraies donnees. En attendant, elle reproduit la structure visible du mockup avec un hero, des actions, un bloc descriptif et des sections futures.',
      trailerLabel: 'Trailer',
      recommendationLabel: 'Recommendation',
      characterLabel: 'Characters',
      episodeProgressLabel: '-/${summary.episodeCount}ep',
      scoreLabel: summary.scoreLabel,
    );
  }
}
