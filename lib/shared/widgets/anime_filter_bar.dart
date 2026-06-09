import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// Barre de filtrage et de tri de l'écran Discover.
///
/// Affiche un bouton "Filtres" (avec le nombre de genres actifs si > 0)
/// et un bouton "Sort" (avec le libellé du tri actif).
/// Les actions sont déléguées via [onFilterTap] et [onSortTap].
class AnimeFilterBar extends StatelessWidget {
  const AnimeFilterBar({
    super.key,
    required this.activeGenreCount,
    required this.sortLabel,
    required this.onFilterTap,
    required this.onSortTap,
  });

  /// Nombre de genres actifs. Affiche un badge dans le bouton si > 0.
  final int activeGenreCount;

  /// Libellé du tri actif affiché sur le bouton Sort.
  final String sortLabel;

  /// Appelé quand l'utilisateur appuie sur le bouton Filtres.
  final VoidCallback onFilterTap;

  /// Appelé quand l'utilisateur appuie sur le bouton Sort.
  final VoidCallback onSortTap;

  @override
  Widget build(BuildContext context) {
    final filterActive = activeGenreCount > 0;

    return Row(
      children: [
        ElevatedButton.icon(
          onPressed: onFilterTap,
          icon: const Icon(Icons.filter_alt_rounded, size: 16),
          label: Text(
            filterActive ? 'Filtres ($activeGenreCount)' : 'Filtres',
          ),
          style: filterActive
              ? ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                )
              : null,
        ),
        const SizedBox(width: 10),
        ElevatedButton.icon(
          onPressed: onSortTap,
          icon: const Icon(Icons.sort_rounded, size: 16),
          label: Text(sortLabel),
        ),
      ],
    );
  }
}
