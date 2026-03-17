import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radii.dart';

class AnimePoster extends StatelessWidget {
  const AnimePoster({
    super.key,
    required this.title,
    this.imageUrl,
    this.width = 74,
    this.height = 104,
    this.compact = false,
  });

  final String title;
  final String? imageUrl;
  final double width;
  final double height;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.md),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF8F0F0),
            Colors.white,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl != null && imageUrl!.isNotEmpty
          ? Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _PosterFallback(
                title: title,
                compact: compact,
              ),
            )
          : _PosterFallback(
              title: title,
              compact: compact,
            ),
    );
  }
}

class _PosterFallback extends StatelessWidget {
  const _PosterFallback({
    required this.title,
    required this.compact,
  });

  final String title;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        compact ? title.substring(0, 1) : title.toUpperCase(),
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.accent,
              fontSize: compact ? 22 : 18,
              fontWeight: FontWeight.w900,
            ),
      ),
    );
  }
}
