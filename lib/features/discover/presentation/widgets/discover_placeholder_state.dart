import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/widgets/anime_section_header.dart';

class DiscoverPlaceholderState extends StatelessWidget {
  const DiscoverPlaceholderState({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const Key('discover_placeholder_state'),
      children: const [
        _PlaceholderSection(title: 'Nom d’une catégorie'),
        SizedBox(height: AppSpacing.lg),
        _PlaceholderSection(title: 'Nom d’une catégorie'),
        SizedBox(height: AppSpacing.lg),
        _PlaceholderSection(title: 'Nom d’une catégorie'),
      ],
    );
  }
}

class _PlaceholderSection extends StatelessWidget {
  const _PlaceholderSection({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimeSectionHeader(title: title),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          key: Key('discover_placeholder_section_list'),
          height: 182,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) => const _PlaceholderTile(),
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemCount: 4,
          ),
        ),
      ],
    );
  }
}

class _PlaceholderTile extends StatelessWidget {
  const _PlaceholderTile();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 94,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 132,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Nom de l’animé trop long',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
