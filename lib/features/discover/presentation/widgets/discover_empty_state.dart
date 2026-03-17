import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';

class DiscoverEmptyState extends StatelessWidget {
  const DiscoverEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      key: const Key('discover_empty_state'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_rounded,
              size: 110,
              color: Colors.white.withValues(alpha: 0.95),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Aucun résultat',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Essaie un autre titre. AniList répond bien, donc si c’est vide c’est juste que la recherche ne matche rien de correct.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
