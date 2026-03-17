import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/widgets/anime_card.dart';
import '../controllers/library_controller.dart';

class LibraryPage extends ConsumerWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final libraryAsync = ref.watch(libraryControllerProvider);
    final libraryController = ref.read(libraryControllerProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Liste',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Ta bibliothèque locale. Pas de sync AniList utilisateur ici pour le moment.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: libraryAsync.when(
                  data: (anime) {
                    if (anime.isEmpty) {
                      return const _EmptyLibraryState();
                    }
                    return ListView.separated(
                      key: const Key('library_results_state'),
                      itemCount: anime.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final item = anime[index];
                        return AnimeCard(
                          anime: item,
                          actionIcon: Icons.bookmark_remove_rounded,
                          actionLabel: 'Retirer',
                          onActionPressed: () =>
                              libraryController.toggleAnime(item),
                          onTap: () => context.push(
                            AppRoutes.animeDetailsLocation(item.id),
                          ),
                        );
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stackTrace) => Center(
                    child: Text('Impossible de charger la liste: $error'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyLibraryState extends StatelessWidget {
  const _EmptyLibraryState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bookmark_outline_rounded,
            size: 72,
            color: AppColors.accentMuted.withValues(alpha: 0.8),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Ta liste est vide',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Ajoute des anime depuis Découvrir pour remplir cet onglet.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
