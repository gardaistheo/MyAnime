import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';

class DiscoverLoadingState extends StatelessWidget {
  const DiscoverLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      key: Key('discover_loading_state'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 72,
            height: 72,
            child: CircularProgressIndicator(strokeWidth: 5),
          ),
          SizedBox(height: AppSpacing.md),
          Text('LOADING...'),
        ],
      ),
    );
  }
}
