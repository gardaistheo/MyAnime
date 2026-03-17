import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/widgets/anime_card.dart';
import '../../../../shared/widgets/anime_filter_bar.dart';
import '../../../../shared/widgets/anime_search_bar.dart';
import '../controllers/discover_controller.dart';
import '../widgets/discover_empty_state.dart';
import '../widgets/discover_loading_state.dart';
import '../widgets/discover_placeholder_state.dart';

class DiscoverPage extends ConsumerStatefulWidget {
  const DiscoverPage({super.key});

  @override
  ConsumerState<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends ConsumerState<DiscoverPage> {
  late final TextEditingController _textController;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _focusNode = FocusNode()
      ..addListener(() {
        ref
            .read(discoverControllerProvider.notifier)
            .setSearchActive(_focusNode.hasFocus);
      });
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(discoverControllerProvider);
    final controller = ref.read(discoverControllerProvider.notifier);

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
                  'Découvrez',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              AnimeSearchBar(
                controller: _textController,
                focusNode: _focusNode,
                showCancel: state.isSearchActive || state.query.isNotEmpty,
                onChanged: controller.updateQuery,
                onCancel: () {
                  _textController.clear();
                  controller.cancelSearch();
                  _focusNode.unfocus();
                },
              ),
              if (state.mode != DiscoverViewMode.placeholder) ...[
                const SizedBox(height: AppSpacing.md),
                const AnimeFilterBar(),
              ],
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: switch (state.mode) {
                    DiscoverViewMode.placeholder =>
                      const DiscoverPlaceholderState(),
                    DiscoverViewMode.idle => const DiscoverEmptyState(),
                    DiscoverViewMode.loading => const DiscoverLoadingState(),
                    DiscoverViewMode.results => _DiscoverResults(
                        animeResults: state.results,
                      ),
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DiscoverResults extends StatelessWidget {
  const _DiscoverResults({required this.animeResults});

  final List<dynamic> animeResults;

  @override
  Widget build(BuildContext context) {
    if (animeResults.isEmpty) {
      return const Center(
        child: Text('Aucun anime trouvé.'),
      );
    }

    return ListView.separated(
      key: const Key('discover_results_state'),
      itemCount: animeResults.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final anime = animeResults[index];
        return AnimeCard(
          anime: anime,
          onTap: () => context.push(AppRoutes.animeDetailsLocation(anime.id)),
        );
      },
    );
  }
}
