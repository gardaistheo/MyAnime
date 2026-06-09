import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_spacing.dart';
import '../../../../../shared/models/anime_summary.dart';

/// Bloc d'actions de la page de détail.
///
/// Contient les pills d'information (épisodes, score), le bouton principal
/// "Suivre" / "Mettre à jour" et le bouton discret "Retirer de la liste".
///
/// Les actions sont déléguées à la page parente via [onFollowPressed] et
/// [onRemovePressed] pour garder ce widget purement présentationnel.
class AnimeActions extends StatelessWidget {
  const AnimeActions({
    super.key,
    required this.episodeCount,
    required this.scoreLabel,
    required this.savedAnime,
    required this.isSaved,
    required this.onFollowPressed,
    required this.onRemovePressed,
  });

  /// Nombre total d'épisodes. `0` si inconnu (série en cours).
  final int episodeCount;

  /// Score formaté pour l'affichage, ex. `"87/100"`.
  final String scoreLabel;

  /// Entrée de la bibliothèque pour cet anime, ou `null` s'il n'est pas suivi.
  final AnimeSummary? savedAnime;

  /// `true` si l'anime est déjà dans la bibliothèque de l'utilisateur.
  final bool isSaved;

  /// Appelé quand l'utilisateur appuie sur "Suivre cet anime" ou "Mettre à jour".
  final Future<void> Function() onFollowPressed;

  /// Appelé quand l'utilisateur appuie sur "Retirer de la liste".
  final VoidCallback onRemovePressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        children: [
          // Pills : progression épisodes et score
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _InfoPill(
                label: episodeCount > 0
                    ? '${savedAnime?.currentEpisode ?? 0}/$episodeCount ep'
                    : 'Épisode ${savedAnime?.currentEpisode ?? 0}',
              ),
              const SizedBox(width: 12),
              _InfoPill(label: scoreLabel),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Bouton principal
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: Icon(
                isSaved ? Icons.edit_rounded : Icons.bookmark_add_rounded,
              ),
              label: Text(
                isSaved ? 'Mettre à jour' : 'Suivre cet anime',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: onFollowPressed,
            ),
          ),
          // Bouton discret "Retirer" — visible uniquement si l'anime est suivi
          if (isSaved) ...[
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: onRemovePressed,
              icon: const Icon(Icons.bookmark_remove_rounded, size: 18),
              label: const Text('Retirer de la liste'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Capsule d'information affichant un [label] sur fond semi-transparent.
///
/// Utilisée pour la progression d'épisodes et le score dans [AnimeActions].
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
