import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';

class AnimeBottomNav extends StatelessWidget {
  const AnimeBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    const items = [
      _NavItem(label: 'Liste', icon: Icons.view_agenda_rounded),
      _NavItem(label: 'Découvrir', icon: Icons.search_rounded),
      _NavItem(label: 'Screen', icon: Icons.auto_awesome_rounded),
      _NavItem(label: 'News', icon: Icons.article_rounded),
      _NavItem(label: 'User', icon: Icons.person_rounded),
    ];

    return Container(
      height: 82,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Row(
        children: [
          for (var index = 0; index < items.length; index++)
            Expanded(
              child: _BottomNavButton(
                key: Key('bottom_nav_$index'),
                item: items[index],
                isSelected: index == currentIndex,
                onTap: () => onTap(index),
              ),
            ),
        ],
      ),
    );
  }
}

class _BottomNavButton extends StatelessWidget {
  const _BottomNavButton({
    super.key,
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final _NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.accent : AppColors.textMuted;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(item.icon, color: color, size: 28),
            const SizedBox(height: 2),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.label,
    required this.icon,
  });

  final String label;
  final IconData icon;
}
