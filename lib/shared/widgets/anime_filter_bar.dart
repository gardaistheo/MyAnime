import 'package:flutter/material.dart';

class AnimeFilterBar extends StatelessWidget {
  const AnimeFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.filter_alt_rounded, size: 16),
          label: const Text('Filter'),
        ),
        const SizedBox(width: 10),
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.sort_rounded, size: 16),
          label: const Text('Sort'),
        ),
      ],
    );
  }
}
