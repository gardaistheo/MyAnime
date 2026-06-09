import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_spacing.dart';

/// Sections textuelles de la page de détail : Synopsis, Genres et Lien AniList.
///
/// Affiche uniquement les sections disponibles :
/// - Genres masqués si [genres] est vide.
/// - Lien AniList masqué si [siteUrl] est vide.
class AnimeContent extends StatelessWidget {
  const AnimeContent({
    super.key,
    required this.description,
    required this.genres,
    required this.siteUrl,
  });

  /// Synopsis nettoyé de l'anime.
  final String description;

  /// Liste des genres. La section Genres est masquée si vide.
  final List<String> genres;

  /// URL de la page AniList. La section Liens est masquée si vide.
  final String siteUrl;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader('Synopsis'),
          const SizedBox(height: AppSpacing.sm),
          Center(
            child: Text(
              description,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          if (genres.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            const _SectionHeader('Genres'),
            const SizedBox(height: AppSpacing.sm),
            Center(
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final genre in genres) _GenreChip(label: genre),
                ],
              ),
            ),
          ],
          if (siteUrl.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            const _SectionHeader('Liens'),
            const SizedBox(height: AppSpacing.sm),
            Center(
              child: TextButton.icon(
                onPressed: () => launchUrl(
                  Uri.parse(siteUrl),
                  mode: LaunchMode.externalApplication,
                ),
                icon: const Icon(Icons.open_in_new_rounded, size: 18),
                label: const Text('Voir sur AniList'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Titre de section en gras, aligné à gauche.
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

/// Chip de genre avec bordure accent et fond semi-transparent.
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
