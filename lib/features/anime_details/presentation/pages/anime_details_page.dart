import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../features/library/presentation/controllers/library_controller.dart';
import '../../../../shared/models/anime_summary.dart';
import '../../../../shared/providers/repositories.dart';
import '../../../../shared/widgets/anime_poster.dart';

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
                  // ── Hero ──────────────────────────────────────────────
                  SizedBox(
                    height: 380,
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
                          bottom: 16,
                          left: 0,
                          right: 0,
                          child: Column(
                            children: [
                              AnimePoster(
                                title: details.title,
                                imageUrl: details.coverImageUrl,
                                width: 120,
                                height: 160,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 24),
                                child: Text(
                                  details.title,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(fontSize: 22),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                details.studio,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Actions ───────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Column(
                      children: [
                        // Info pills
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _InfoPill(
                              label: details.episodeCount > 0
                                  ? '${savedAnime?.currentEpisode ?? 0}/${details.episodeCount} ep'
                                  : 'Épisode ${savedAnime?.currentEpisode ?? 0}',
                            ),
                            const SizedBox(width: 12),
                            _InfoPill(label: details.scoreLabel),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        // Primary action — prominent
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              foregroundColor: Colors.white,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            icon: Icon(
                              isSaved
                                  ? Icons.edit_rounded
                                  : Icons.bookmark_add_rounded,
                            ),
                            label: Text(
                              isSaved ? 'Mettre à jour' : 'Suivre cet anime',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
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
                        ),
                        if (isSaved) ...[
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: () =>
                                libraryController.toggleAnime(savedAnime),
                            icon: const Icon(
                                Icons.bookmark_remove_rounded,
                                size: 18),
                            label: const Text('Retirer de la liste'),
                            style: TextButton.styleFrom(
                                foregroundColor: AppColors.textMuted),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // ── Sections de contenu ───────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _SectionHeader('Synopsis'),
                        const SizedBox(height: AppSpacing.sm),
                        Center(
                          child: Text(
                            details.description,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                        if (details.genres.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.lg),
                          const _SectionHeader('Genres'),
                          const SizedBox(height: AppSpacing.sm),
                          Center(
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                for (final genre in details.genres)
                                  _GenreChip(label: genre),
                              ],
                            ),
                          ),
                        ],
                        if (details.siteUrl.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.lg),
                          const _SectionHeader('Liens'),
                          const SizedBox(height: AppSpacing.sm),
                          Center(
                            child: TextButton.icon(
                              onPressed: () => launchUrl(
                                Uri.parse(details.siteUrl),
                                mode: LaunchMode.externalApplication,
                              ),
                              icon: const Icon(
                                  Icons.open_in_new_rounded,
                                  size: 18),
                              label: const Text('Voir sur AniList'),
                            ),
                          ),
                        ],
                      ],
                    ),
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

Future<int?> _showEpisodePicker(
  BuildContext context, {
  required int maxEpisodes,
  int? initialEpisode,
}) async {
  final textController = TextEditingController(
    text: (initialEpisode ?? 0).toString(),
  );

  return showDialog<int>(
    context: context,
    builder: (dialogContext) {
      String? errorText;

      return StatefulBuilder(
        builder: (ctx, setState) {
          return AlertDialog(
            title: const Text('Épisode actuel'),
            content: TextField(
              key: const Key('episode_progress_field'),
              controller: textController,
              autofocus: true,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: maxEpisodes > 0
                    ? 'Entre 0 et $maxEpisodes'
                    : 'Numéro d\'épisode',
                errorText: errorText,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () {
                  final parsed =
                      int.tryParse(textController.text.trim());
                  if (parsed == null || parsed < 0) {
                    setState(
                        () => errorText = 'Entrez un numéro valide');
                    return;
                  }
                  if (maxEpisodes > 0 && parsed > maxEpisodes) {
                    setState(() => errorText =
                        'Cet anime n\'a que $maxEpisodes épisodes');
                    return;
                  }
                  Navigator.of(dialogContext).pop(parsed);
                },
                child: const Text('Enregistrer'),
              ),
            ],
          );
        },
      );
    },
  );
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }
}

class _GenreChip extends StatelessWidget {
  const _GenreChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: Theme.of(context)
            .textTheme
            .labelMedium
            ?.copyWith(color: AppColors.accentMuted),
      ),
    );
  }
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
