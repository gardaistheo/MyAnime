import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../features/library/presentation/controllers/library_controller.dart';
import '../../../../shared/models/anime_summary.dart';
import '../../../../shared/providers/repositories.dart';
import '../widgets/anime_actions.dart';
import '../widgets/anime_content.dart';
import '../widgets/anime_hero.dart';
import '../widgets/episode_picker_dialog.dart';

/// Page de détail d'un anime identifié par [animeId].
///
/// Orchestre les quatre blocs :
/// - [AnimeHero] : gradient + affiche + titre + studio
/// - [AnimeActions] : pills info + bouton Suivre/Mettre à jour
/// - [AnimeContent] : Synopsis, Genres, Lien AniList
///
/// La récupération des données passe par [animeDetailsProvider] (AniList).
/// Le suivi de l'utilisateur passe par [libraryControllerProvider] (local).
class AnimeDetailsPage extends ConsumerWidget {
  const AnimeDetailsPage({
    super.key,
    required this.animeId,
  });

  /// Identifiant AniList de l'anime à afficher.
  final String animeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailsAsync = ref.watch(animeDetailsProvider(animeId));

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: detailsAsync.when(
          data: (details) {
            final savedAnime = ref.watch(libraryAnimeProvider(details.id));
            final isSaved = savedAnime != null;
            final libraryController =
                ref.read(libraryControllerProvider.notifier);

            // AnimeSummary construit à partir des détails pour la persistance
            final libraryAnime = AnimeSummary(
              id: details.id,
              title: details.title,
              subtitle:
                  '${details.studio} • ${details.episodeCount > 0 ? '${details.episodeCount} ep' : 'Épisodes ?'}',
              description: details.description,
              tags: details.genres,
              episodeCount: details.episodeCount,
              scoreLabel: details.scoreLabel,
              coverImageUrl: details.coverImageUrl,
              studio: details.studio,
              averageScore: details.averageScore,
              siteUrl: details.siteUrl,
              currentEpisode: savedAnime?.currentEpisode ?? 0,
            );

            return SingleChildScrollView(
              key: const Key('anime_details_page'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AnimeHero(
                    title: details.title,
                    studio: details.studio,
                    coverImageUrl: details.coverImageUrl,
                  ),
                  AnimeActions(
                    episodeCount: details.episodeCount,
                    scoreLabel: details.scoreLabel,
                    savedAnime: savedAnime,
                    isSaved: isSaved,
                    onFollowPressed: () async {
                      final selectedEpisode = await showEpisodePicker(
                        context,
                        initialEpisode: savedAnime?.currentEpisode,
                        maxEpisodes: details.episodeCount,
                      );
                      if (selectedEpisode == null || !context.mounted) return;
                      await libraryController.saveProgress(
                          libraryAnime, selectedEpisode);
                    },
                    onRemovePressed: () =>
                        libraryController.toggleAnime(savedAnime!),
                  ),
                  AnimeContent(
                    description: details.description,
                    genres: details.genres,
                    siteUrl: details.siteUrl,
                  ),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Impossible de charger la fiche anime.',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () =>
                        ref.invalidate(animeDetailsProvider(animeId)),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
