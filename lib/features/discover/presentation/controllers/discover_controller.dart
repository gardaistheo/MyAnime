import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/anime_summary.dart';
import '../../../../shared/providers/repositories.dart';

/// Mode d'affichage de l'écran Discover.
enum DiscoverViewMode {
  /// Chargement en cours (shimmer affiché).
  loading,

  /// Des résultats sont disponibles.
  results,

  /// La requête a réussi mais n'a retourné aucun résultat.
  empty,

  /// Une erreur réseau ou API est survenue.
  error,
}

/// État immuable de l'écran Discover.
class DiscoverState {
  const DiscoverState({
    required this.mode,
    required this.query,
    required this.results,
    required this.isSearchActive,
    required this.errorMessage,
  });

  /// État initial : chargement en cours, sans query ni résultats.
  const DiscoverState.initial()
      : mode = DiscoverViewMode.loading,
        query = '',
        results = const [],
        isSearchActive = false,
        errorMessage = null;

  /// Mode d'affichage courant.
  final DiscoverViewMode mode;

  /// Texte de recherche actif (chaîne vide si on affiche le trending).
  final String query;

  /// Liste d'animes à afficher.
  final List<AnimeSummary> results;

  /// `true` si la barre de recherche est ouverte (affichage du champ texte).
  final bool isSearchActive;

  /// Message d'erreur, non nul uniquement si [mode] est [DiscoverViewMode.error].
  final String? errorMessage;

  /// Retourne une copie avec les champs surchargés.
  ///
  /// [clearError] met [errorMessage] à `null`.
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

/// Provider du controller Discover.
final discoverControllerProvider =
    NotifierProvider<DiscoverController, DiscoverState>(DiscoverController.new);

/// Gestionnaire d'état de l'écran Discover (trending + recherche).
///
/// Gère les requêtes réseau avec un mécanisme anti-course : chaque requête
/// reçoit un identifiant [_requestId] incrémental. Si une requête plus récente
/// est lancée avant que la précédente ne termine, son résultat est ignoré.
class DiscoverController extends Notifier<DiscoverState> {
  /// Compteur de requêtes pour détecter les résultats obsolètes.
  int _requestId = 0;

  @override
  DiscoverState build() => const DiscoverState.initial();

  /// Affiche ou masque la barre de recherche.
  void setSearchActive(bool isActive) {
    state = state.copyWith(isSearchActive: isActive);
  }

  /// Charge les animes tendance. Appelé au démarrage de l'écran.
  Future<void> loadInitial() async {
    await _runRequest(
      query: '',
      loader: () => ref.read(animeRepositoryProvider).fetchTrendingAnime(),
    );
  }

  /// Ferme la recherche et revient aux animes tendance.
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

  /// Met à jour la recherche avec le nouveau texte [query].
  ///
  /// Si [query] est vide après trim, revient aux animes tendance.
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

  /// Exécute [loader] en protégeant contre les réponses périmées.
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
      // Ignorer si une requête plus récente a été lancée entre-temps.
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
