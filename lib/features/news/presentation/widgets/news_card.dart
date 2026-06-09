import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_radii.dart';
import '../../../../../app/theme/app_spacing.dart';
import '../../../../../shared/models/anime_summary.dart';

/// Card d'un anime en cours de diffusion dans l'écran News.
///
/// Affiche la cover arrondie, le badge "En cours", le titre, le studio,
/// un extrait de synopsis et les 3 premiers genres.
/// Navigue vers la page de détail au tap via [onTap].
class NewsCard extends StatelessWidget {
  const NewsCard({
    super.key,
    required this.anime,
    required this.onTap,
  });

  /// Anime à afficher.
  final AnimeSummary anime;

  /// Appelé quand l'utilisateur tape sur la card.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceRaised,
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover — image inset avec coins arrondis sur les 4 côtés
            Padding(
              padding: const EdgeInsets.all(8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadii.md),
                child: SizedBox(
                  width: 80,
                  height: 114,
                  child: anime.coverImageUrl.isNotEmpty
                      ? Image.network(
                          anime.coverImageUrl,
                          width: 80,
                          height: 114,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) =>
                              _CoverFallback(title: anime.title),
                        )
                      : _CoverFallback(title: anime.title),
                ),
              ),
            ),
            // Informations textuelles
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: _NewsCardInfo(anime: anime),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(AppSpacing.sm),
              child: Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bloc d'informations textuelles de la card (badge, titre, studio, synopsis, genres).
class _NewsCardInfo extends StatelessWidget {
  const _NewsCardInfo({required this.anime});

  final AnimeSummary anime;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Badge "En cours"
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'En cours',
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: AppColors.success),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          anime.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 4),
        Text(
          anime.subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: AppColors.textMuted),
        ),
        const SizedBox(height: 6),
        Text(
          anime.description,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        if (anime.tags.isNotEmpty) ...[
          const SizedBox(height: 6),
          Wrap(
            spacing: 4,
            children: [
              for (final tag in anime.tags.take(3))
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    tag,
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall
                        ?.copyWith(color: AppColors.textSecondary),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

/// Fallback affiché quand la cover n'est pas disponible.
///
/// Montre la première lettre du titre sur fond neutre.
class _CoverFallback extends StatelessWidget {
  const _CoverFallback({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceMuted,
      child: Center(
        child: Text(
          title.isNotEmpty ? title[0] : '?',
          style: Theme.of(context)
              .textTheme
              .headlineLarge
              ?.copyWith(color: AppColors.textMuted),
        ),
      ),
    );
  }
}
