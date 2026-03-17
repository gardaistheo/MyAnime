import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/widgets/anime_primary_button.dart';
import '../../data/models/trace_moe_result.dart';
import '../controllers/screen_controller.dart';

class ScreenSearchPage extends ConsumerWidget {
  const ScreenSearchPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(screenControllerProvider);
    final controller = ref.read(screenControllerProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
          children: [
            Center(
              child: Text(
                'Screen',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Balance un screenshot d’anime et on tente de retrouver le titre, l’épisode et la confiance du match avec trace.moe.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: AppSpacing.lg),
            _SelectedImageCard(image: state.selectedImage),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: AnimePrimaryButton(
                    label: state.selectedImage == null
                        ? 'Choisir un screenshot'
                        : 'Changer l’image',
                    onPressed: controller.pickAndAnalyzeScreenshot,
                  ),
                ),
                if (state.selectedImage != null) ...[
                  const SizedBox(width: AppSpacing.sm),
                  IconButton.filledTonal(
                    key: const Key('screen_clear_button'),
                    onPressed: controller.clear,
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Limites doc API: 25MB max, quota gratuit ~100 recherches / 24h / IP. Dans cette app, on considère qu’au-dessus de 80% c’est déjà plutôt bon.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.lg),
            switch (state.status) {
              ScreenStatus.idle => const _InfoBlock(
                  key: Key('screen_idle_state'),
                  title: 'Aucun screenshot',
                  message:
                      'Choisis une image depuis la galerie. Les screenshots propres marchent mieux que les recadrages dégueulasses.',
                  icon: Icons.image_search_rounded,
                ),
              ScreenStatus.picking => const _InfoBlock(
                  key: Key('screen_picking_state'),
                  title: 'Sélection en cours',
                  message: 'On attend juste ton image.',
                  icon: Icons.photo_library_rounded,
                ),
              ScreenStatus.searching => const _LoadingBlock(),
              ScreenStatus.error => _ErrorBlock(
                  message: state.errorMessage ?? 'Erreur inconnue.',
                  onRetry: state.selectedImage == null
                      ? controller.pickAndAnalyzeScreenshot
                      : () =>
                          controller.analyzeScreenshot(state.selectedImage!),
                ),
              ScreenStatus.success => _ResultsBlock(results: state.results),
            },
          ],
        ),
      ),
    );
  }
}

class _SelectedImageCard extends StatelessWidget {
  const _SelectedImageCard({required this.image});

  final Uint8List? image;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      clipBehavior: Clip.antiAlias,
      child: image == null
          ? const Center(
              child: Icon(
                Icons.photo_size_select_large_rounded,
                size: 72,
                color: AppColors.textMuted,
              ),
            )
          : Image.memory(
              image!,
              key: const Key('screen_selected_image'),
              fit: BoxFit.cover,
              width: double.infinity,
            ),
    );
  }
}

class _InfoBlock extends StatelessWidget {
  const _InfoBlock({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
  });

  final String title;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: Column(
        children: [
          Icon(icon, size: 56, color: AppColors.accentMuted),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}

class _LoadingBlock extends StatelessWidget {
  const _LoadingBlock();

  @override
  Widget build(BuildContext context) {
    return const _InfoBlock(
      key: Key('screen_loading_state'),
      title: 'Analyse en cours',
      message: 'On envoie ton screenshot à trace.moe et on attend les matchs.',
      icon: Icons.hourglass_top_rounded,
    );
  }
}

class _ErrorBlock extends StatelessWidget {
  const _ErrorBlock({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('screen_error_state'),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 54, color: Colors.orangeAccent),
          const SizedBox(height: AppSpacing.md),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          AnimePrimaryButton(
            label: 'Réessayer',
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}

class _ResultsBlock extends StatelessWidget {
  const _ResultsBlock({required this.results});

  final List<TraceMoeResult> results;

  @override
  Widget build(BuildContext context) {
    final topResult = results.first;

    return Column(
      key: const Key('screen_results_state'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Meilleur match',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppSpacing.sm),
        _TopResultCard(result: topResult),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Autres résultats',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppSpacing.sm),
        for (final result in results.skip(1).take(3)) ...[
          _CompactResultCard(result: result),
          const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}

class _TopResultCard extends StatelessWidget {
  const _TopResultCard({required this.result});

  final TraceMoeResult result;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (result.previewImageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadii.md),
              child: Image.network(
                result.previewImageUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) =>
                    _PreviewFallback(title: result.title),
              ),
            )
          else
            _PreviewFallback(title: result.title),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetaChip(
                label:
                    '${result.confidenceLabel} • ${result.similarityPercent}',
                isStrong: result.isLikelyMatch,
              ),
              _MetaChip(label: result.episodeLabel),
              _MetaChip(label: result.timestampLabel),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            result.title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Fichier source: ${result.filename}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            result.isLikelyMatch
                ? 'Le score est assez haut pour être considéré comme bon dans cette app.'
                : 'Le score reste faible. Ça peut matcher visuellement sans être le bon anime.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}

class _CompactResultCard extends StatelessWidget {
  const _CompactResultCard({required this.result});

  final TraceMoeResult result;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.movie_creation_outlined),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '${result.episodeLabel} • ${result.similarityPercent}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.label,
    this.isStrong = false,
  });

  final String label;
  final bool isStrong;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isStrong
            ? AppColors.success.withValues(alpha: 0.18)
            : Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium,
      ),
    );
  }
}

class _PreviewFallback extends StatelessWidget {
  const _PreviewFallback({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF64748B),
            Color(0xFF1E293B),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Center(
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
