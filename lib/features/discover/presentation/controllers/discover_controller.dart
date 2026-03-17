import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/anime_summary.dart';
import '../../../../shared/providers/repositories.dart';

enum DiscoverViewMode { loading, results, empty, error }

class DiscoverState {
  const DiscoverState({
    required this.mode,
    required this.query,
    required this.results,
    required this.isSearchActive,
    required this.errorMessage,
  });

  const DiscoverState.initial()
      : mode = DiscoverViewMode.loading,
        query = '',
        results = const [],
        isSearchActive = false,
        errorMessage = null;

  final DiscoverViewMode mode;
  final String query;
  final List<AnimeSummary> results;
  final bool isSearchActive;
  final String? errorMessage;

  DiscoverState copyWith({
    DiscoverViewMode? mode,
    String? query,
    List<AnimeSummary>? results,
    bool? isSearchActive,
    String? errorMessage,
    bool clearError = false,
  }) {
    return DiscoverState(
      mode: mode ?? this.mode,
      query: query ?? this.query,
      results: results ?? this.results,
      isSearchActive: isSearchActive ?? this.isSearchActive,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
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
    state = state.copyWith(isSearchActive: isActive);
  }

  Future<void> loadInitial() async {
    await _runRequest(
      query: '',
      loader: () => ref.read(animeRepositoryProvider).fetchTrendingAnime(),
    );
  }

  Future<void> cancelSearch() async {
    _requestId++;
    state = state.copyWith(
      query: '',
      results: const [],
      clearError: true,
      mode: DiscoverViewMode.loading,
    );
    await loadInitial();
  }

  Future<void> updateQuery(String query) async {
    final trimmed = query.trim();

    if (trimmed.isEmpty) {
      state = state.copyWith(query: '');
      await loadInitial();
      return;
    }

    await _runRequest(
      query: trimmed,
      loader: () => ref.read(animeRepositoryProvider).searchAnime(trimmed),
    );
  }

  Future<void> _runRequest({
    required String query,
    required Future<List<AnimeSummary>> Function() loader,
  }) async {
    _requestId++;
    final currentRequest = _requestId;

    state = state.copyWith(
      query: query,
      mode: DiscoverViewMode.loading,
      results: const [],
      clearError: true,
    );

    try {
      final results = await loader();
      if (currentRequest != _requestId) {
        return;
      }

      state = state.copyWith(
        query: query,
        results: results,
        mode:
            results.isEmpty ? DiscoverViewMode.empty : DiscoverViewMode.results,
      );
    } catch (error) {
      if (currentRequest != _requestId) {
        return;
      }
      state = state.copyWith(
        query: query,
        results: const [],
        errorMessage: '$error',
        mode: DiscoverViewMode.error,
      );
    }
  }
}
