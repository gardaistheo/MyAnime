import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

class AnimeSearchBar extends StatelessWidget {
  const AnimeSearchBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.showCancel,
    required this.onChanged,
    required this.onCancel,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool showCancel;
  final ValueChanged<String> onChanged;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            key: const Key('discover_search_field'),
            controller: controller,
            focusNode: focusNode,
            onChanged: onChanged,
            style: Theme.of(context).textTheme.bodyLarge,
            decoration: const InputDecoration(
              hintText: 'Search',
              prefixIcon: Icon(Icons.search_rounded),
              isDense: true,
            ),
          ),
        ),
        if (showCancel) ...[
          const SizedBox(width: 10),
          GestureDetector(
            key: const Key('discover_cancel_button'),
            onTap: onCancel,
            child: Text(
              'Cancel',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                  ),
            ),
          ),
        ],
      ],
    );
  }
}
