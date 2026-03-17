import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/anime_summary.dart';
import '../../../../shared/providers/repositories.dart';

enum DiscoverViewMode { placeholder, idle, loading, results }

class DiscoverState {
  const DiscoverState({
    required this.mode,
    required this.query,
    required this.results,
    required this.isSearchActive,
  });

  const DiscoverState.initial()
      : mode = DiscoverViewMode.placeholder,
        query = '',
        results = const [],
        isSearchActive = false;

  final DiscoverViewMode mode;
  final String query;
  final List<AnimeSummary> results;
  final bool isSearchActive;

  DiscoverState copyWith({
    DiscoverViewMode? mode,
    String? query,
    List<AnimeSummary>? results,
    bool? isSearchActive,
  }) {
    return DiscoverState(
      mode: mode ?? this.mode,
      query: query ?? this.query,
      results: results ?? this.results,
      isSearchActive: isSearchActive ?? this.isSearchActive,
    );
  }
}

final discoverControllerProvider =
    NotifierProvider<DiscoverController, DiscoverState>(DiscoverController.new);

class DiscoverController extends Notifier<DiscoverState> {
  int _requestId = 0;

  @override
  DiscoverState build() => const DiscoverState.initial();

  void setSearchActive(bool isActive) {
    final nextMode = state.query.trim().isNotEmpty
        ? state.mode
        : (isActive ? DiscoverViewMode.idle : DiscoverViewMode.placeholder);

    state = state.copyWith(
      isSearchActive: isActive,
      mode: nextMode,
    );
  }

  void cancelSearch() {
    _requestId++;
    state = const DiscoverState.initial();
  }

  Future<void> updateQuery(String query) async {
    final trimmed = query.trim();
    _requestId++;
    final currentRequest = _requestId;

    if (trimmed.isEmpty) {
      state = state.copyWith(
        query: '',
        results: const [],
        mode: state.isSearchActive
            ? DiscoverViewMode.idle
            : DiscoverViewMode.placeholder,
      );
      return;
    }

    state = state.copyWith(
      query: trimmed,
      mode: DiscoverViewMode.loading,
      results: const [],
    );

    await Future<void>.delayed(const Duration(milliseconds: 550));
    final results =
        await ref.read(animeRepositoryProvider).searchAnime(trimmed);

    if (currentRequest != _requestId) {
      return;
    }

    state = state.copyWith(
      query: trimmed,
      results: results,
      mode: DiscoverViewMode.results,
    );
  }
}
