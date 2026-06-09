import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_spacing.dart';
import '../../../../../shared/widgets/anime_poster.dart';

/// Bloc hero de la page de détail : gradient de fond, affiche, titre et studio.
///
/// Occupe une hauteur fixe de 380 px. Le bouton de retour est intégré
/// dans ce widget pour qu'il reste positionné sur le gradient.
class AnimeHero extends StatelessWidget {
  const AnimeHero({
    super.key,
    required this.title,
    required this.studio,
    required this.coverImageUrl,
  });

  /// Titre principal de l'anime (affiché centré sous l'affiche).
  final String title;

  /// Nom du studio de production principal.
  final String studio;

  /// URL de la bannière ou de la cover (grande image AniList).
  final String coverImageUrl;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
                  title: title,
                  imageUrl: coverImageUrl,
                  width: 120,
                  height: 160,
                ),
                const SizedBox(height: AppSpacing.md),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontSize: 22),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  studio,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
