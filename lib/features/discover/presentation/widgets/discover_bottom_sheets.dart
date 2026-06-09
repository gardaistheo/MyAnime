import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_spacing.dart';
import '../controllers/discover_controller.dart';

/// Bottom sheet de filtrage par genre.
///
/// Affiche les genres disponibles dans les résultats courants sous forme de chips
/// multi-sélection. La sélection met à jour [DiscoverState.selectedGenres] en
/// temps réel via [DiscoverController.setGenres].
class DiscoverFilterSheet extends ConsumerWidget {
  const DiscoverFilterSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(discoverControllerProvider);
    final controller = ref.read(discoverControllerProvider.notifier);
    final genres = state.availableGenres;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Indicateur de drag
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textMuted.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            // En-tête
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filtrer par genre',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (state.selectedGenres.isNotEmpty)
                  TextButton(
                    onPressed: () => controller.setGenres(const <String>{}),
                    child: const Text('Effacer'),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            if (genres.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: Text(
                  'Aucun genre disponible.',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors.textMuted),
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final genre in genres)
                    _GenreChip(
                      label: genre,
                      selected: state.selectedGenres.contains(genre),
                      onTap: () {
                        final updated = Set<String>.from(state.selectedGenres);
                        if (updated.contains(genre)) {
                          updated.remove(genre);
                        } else {
                          updated.add(genre);
                        }
                        controller.setGenres(updated);
                      },
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

/// Chip de genre sélectionnable.
class _GenreChip extends StatelessWidget {
  const _GenreChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.accent
              : AppColors.accent.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? AppColors.accent
                : AppColors.accent.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: selected ? Colors.white : AppColors.accentMuted,
                fontWeight:
                    selected ? FontWeight.w600 : FontWeight.normal,
              ),
        ),
      ),
    );
  }
}

/// Bottom sheet de choix du tri.
///
/// Affiche les options de [DiscoverSortOption] sous forme de tuiles radio.
/// La sélection met à jour [DiscoverState.sortOption] immédiatement et ferme
/// la feuille.
class DiscoverSortSheet extends ConsumerWidget {
  const DiscoverSortSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSort = ref.watch(
      discoverControllerProvider.select((s) => s.sortOption),
    );
    final controller = ref.read(discoverControllerProvider.notifier);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Indicateur de drag
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textMuted.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Trier par',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            RadioGroup<DiscoverSortOption>(
              groupValue: currentSort,
              onChanged: (selected) {
                if (selected != null) {
                  controller.setSortOption(selected);
                  Navigator.of(context).pop();
                }
              },
              child: Column(
                children: [
                  for (final option in DiscoverSortOption.values)
                    RadioListTile<DiscoverSortOption>(
                      value: option,
                      title: Text(option.label),
                      activeColor: AppColors.accent,
                      contentPadding: EdgeInsets.zero,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
