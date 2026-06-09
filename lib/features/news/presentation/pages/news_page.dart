import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../controllers/news_controller.dart';
import '../widgets/news_card.dart';

/// Page News : liste des animes actuellement en cours de diffusion.
///
/// Affiche les données issues de [NewsController] (AniList, status RELEASING).
/// Supporte le pull-to-refresh et le rechargement manuel via l'icône en entête.
class NewsPage extends ConsumerWidget {
  const NewsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newsAsync = ref.watch(newsControllerProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _NewsHeader(
              onRefresh: () =>
                  ref.read(newsControllerProvider.notifier).refresh(),
            ),
            Expanded(
              child: newsAsync.when(
                data: (items) => items.isEmpty
                    ? const Center(child: Text('Aucun anime en cours.'))
                    : RefreshIndicator(
                        onRefresh: () => ref
                            .read(newsControllerProvider.notifier)
                            .refresh(),
                        child: ListView.separated(
                          padding:
                              const EdgeInsets.fromLTRB(16, 0, 16, 40),
                          itemCount: items.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) => NewsCard(
                            anime: items[index],
                            onTap: () => context.push(
                              AppRoutes.animeDetailsLocation(items[index].id),
                            ),
                          ),
                        ),
                      ),
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (_, __) => _NewsError(
                  onRetry: () =>
                      ref.read(newsControllerProvider.notifier).refresh(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// En-tête de la page News : titre, sous-titre et bouton de rafraîchissement.
class _NewsHeader extends StatelessWidget {
  const _NewsHeader({required this.onRefresh});

  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Actu',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              IconButton(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh_rounded),
                tooltip: 'Actualiser',
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, AppSpacing.md),
          child: Text(
            'Animes en cours de diffusion',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppColors.textMuted),
          ),
        ),
      ],
    );
  }
}

/// État d'erreur de la page News avec bouton Réessayer.
class _NewsError extends StatelessWidget {
  const _NewsError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              size: 48,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Impossible de charger l\'actu.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            TextButton(
              onPressed: onRetry,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
}
