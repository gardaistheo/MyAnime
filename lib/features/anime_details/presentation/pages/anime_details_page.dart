import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../features/library/presentation/controllers/library_controller.dart';
import '../../../../shared/models/anime_summary.dart';
import '../../../../shared/providers/repositories.dart';
import '../../../../shared/widgets/anime_poster.dart';
import '../../../../shared/widgets/anime_primary_button.dart';

class AnimeDetailsPage extends ConsumerWidget {
  const AnimeDetailsPage({
    super.key,
    required this.animeId,
  });

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
            final libraryAnime = AnimeSummary(
              id: details.id,
              title: details.title,
              subtitle:
                  '${details.studio} • ${details.episodeCount > 0 ? '${details.episodeCount} ep' : 'Épisodes ?'}',
              description: details.description,
              tags: const [],
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
                  SizedBox(
                    height: 430,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color(0xFF5C7387),
                                AppColors.backgroundBottom,
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          top: 12,
                          left: 12,
                          child: IconButton(
                            onPressed: () => Navigator.of(context).maybePop(),
                            icon: const Icon(Icons.arrow_back_ios_new_rounded),
                          ),
                        ),
                        Positioned(
                          bottom: 96,
                          left: 0,
                          right: 0,
                          child: Column(
                            children: [
                              AnimePoster(
                                title: details.title,
                                imageUrl: details.coverImageUrl,
                                width: 132,
                                height: 176,
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              Text(
                                details.title,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(fontSize: 26),
                              ),
                              Text(
                                details.studio,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          left: 20,
                          right: 20,
                          bottom: 24,
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 12,
                            runSpacing: 10,
                            children: [
                              AnimePrimaryButton(
                                label: isSaved
                                    ? 'Mettre à jour'
                                    : 'Suivre cet anime',
                                onPressed: () async {
                                  final selectedEpisode =
                                      await _showEpisodePicker(
                                    context,
                                    initialEpisode: savedAnime?.currentEpisode,
                                    maxEpisodes: details.episodeCount,
                                  );
                                  if (selectedEpisode == null ||
                                      !context.mounted) {
                                    return;
                                  }

                                  await libraryController.saveProgress(
                                    libraryAnime,
                                    selectedEpisode,
                                  );
                                },
                              ),
                              _InfoPill(
                                label: details.episodeCount > 0
                                    ? '${savedAnime?.currentEpisode ?? 0}/${details.episodeCount} ep'
                                    : 'Épisode ${savedAnime?.currentEpisode ?? 0}',
                              ),
                              _InfoPill(label: details.scoreLabel),
                              if (isSaved)
                                TextButton(
                                  onPressed: () =>
                                      libraryController.toggleAnime(
                                    savedAnime,
                                  ),
                                  child: const Text('Retirer'),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 48),
                    child: Column(
                      children: [
                        Text(
                          'Synopsis',
                          style: Theme.of(context).textTheme.titleLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Text(
                          '${details.description}\n\n${details.recommendationLabel}\n${details.characterLabel}\n${details.trailerLabel}\nRéseaux',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(
            child: Text(
              'Impossible de charger la fiche anime.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ),
      ),
    );
  }
}

Future<int?> _showEpisodePicker(
  BuildContext context, {
  required int maxEpisodes,
  int? initialEpisode,
}) async {
  final controller = TextEditingController(
    text: (initialEpisode ?? 0).toString(),
  );

  return showDialog<int>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Épisode actuel'),
        content: TextField(
          key: const Key('episode_progress_field'),
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: maxEpisodes > 0
                ? 'Entre 0 et $maxEpisodes'
                : 'Numéro d’épisode',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              final parsedValue = int.tryParse(controller.text.trim());
              if (parsedValue == null || parsedValue < 0) {
                return;
              }

              final nextEpisode = maxEpisodes > 0
                  ? parsedValue.clamp(0, maxEpisodes)
                  : parsedValue;
              Navigator.of(dialogContext).pop(nextEpisode);
            },
            child: const Text('Enregistrer'),
          ),
        ],
      );
    },
  );
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge,
      ),
    );
  }
}
