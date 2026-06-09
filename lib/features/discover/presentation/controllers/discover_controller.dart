import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/anime_summary.dart';
import '../../../../shared/providers/repositories.dart';

/// Options de tri des résultats dans l'écran Discover.
enum DiscoverSortOption {
  trending,
  score,
  titleAZ;

  /// Libellé court affiché sur le bouton Sort.
  String get label => switch (this) {
        DiscoverSortOption.trending => 'Tendance',
        DiscoverSortOption.score => 'Score',
        DiscoverSortOption.titleAZ => 'Titre A-Z',
      };

  /// Retourne [list] triée selon cette option (nouvelle liste, sans mutation).
  List<AnimeSummary> apply(List<AnimeSummary> list) => switch (this) {
        DiscoverSortOption.trending => list,
        DiscoverSortOption.score => [...list]
          ..sort((a, b) => b.averageScore.compareTo(a.averageScore)),
        DiscoverSortOption.titleAZ => [...list]
          ..sort(
              (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase())),
      };
}

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
    required this.rawResults,
    required this.selectedGenres,
    required this.sortOption,
    required this.isSearchActive,
    required this.errorMessage,
  });

  /// État initial : chargement en cours, sans query ni résultats.
  const DiscoverState.initial()
      : mode = DiscoverViewMode.loading,
        query = '',
        rawResults = const [],
        selectedGenres = const <String>{},
        sortOption = DiscoverSortOption.trending,
        isSearchActive = false,
        errorMessage = null;

  /// Mode d'affichage courant.
  final DiscoverViewMode mode;

  /// Texte de recherche actif (chaîne vide = trending).
  final String query;

  /// Résultats bruts retournés par l'API, avant filtrage et tri.
  final List<AnimeSummary> rawResults;

  /// Genres sélectionnés pour le filtrage (multi-sélection).
  final Set<String> selectedGenres;

  /// Option de tri active.
  final DiscoverSortOption sortOption;

  /// `true` si la barre de recherche est ouverte.
  final bool isSearchActive;

  /// Message d'erreur, non nul uniquement si [mode] est [DiscoverViewMode.error].
  final String? errorMessage;

  /// Genres disponibles dans les résultats bruts, triés alphabétiquement.
  ///
  /// Seuls les genres effectivement présents dans [rawResults] sont retournés,
  /// ce qui garantit que chaque filtre proposé a au moins un résultat.
  List<String> get availableGenres =>
      rawResults.expand((a) => a.tags).toSet().toList()..sort();

  /// Résultats après application des filtres de genre et du tri actif.
  ///
  /// C'est cette liste que l'interface doit afficher.
  List<AnimeSummary> get displayResults {
    var list = rawResults;
    if (selectedGenres.isNotEmpty) {
      list = list
          .where((a) => a.tags.any(selectedGenres.contains))
          .toList();
    }
    return sortOption.apply(list);
  }

  /// Retourne une copie avec les champs surchargés.
  ///
  /// [clearError] remet [errorMessage] à `null`.
  /// [clearGenres] vide [selectedGenres].
  DiscoverState copyWith({
    DiscoverViewMode? mode,
    String? query,
    List<AnimeSummary>? rawResults,
    Set<String>? selectedGenres,
    DiscoverSortOption? sortOption,
    bool? isSearchActive,
    String? errorMessage,
    bool clearError = false,
    bool clearGenres = false,
  }) {
    return DiscoverState(
      mode: mode ?? this.mode,
      query: query ?? this.query,
      rawResults: rawResults ?? this.rawResults,
      selectedGenres:
          clearGenres ? const <String>{} : (selectedGenres ?? this.selectedGenres),
      sortOption: sortOption ?? this.sortOption,
      isSearchActive: isSearchActive ?? this.isSearchActive,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// Provider du controller Discover.
final discoverControllerProvider =
    NotifierProvider<DiscoverController, DiscoverState>(DiscoverController.new);

/// Gestionnaire d'état de l'écran Discover (trending + recherche + filtres + tri).
///
/// Gère les requêtes réseau avec un mécanisme anti-course : chaque requête
/// reçoit un identifiant [_requestId] incrémental. Si une requête plus récente
/// est lancée avant que la précédente ne termine, son résultat est ignoré.
///
/// Le filtrage et le tri sont effectués côté client via [DiscoverState.displayResults] :
/// ils ne déclenchent pas de nouveau appel réseau.
class DiscoverController extends Notifier<DiscoverState> {
  /// Compteur de requêtes pour détecter les résultats obsolètes.
  int _requestId = 0;

  @override
  DiscoverState build() => const DiscoverState.initial();

  /// Affiche ou masque la barre de recherche.
  void setSearchActive(bool isActive) {
    state = state.copyWith(isSearchActive: isActive);
  }

  /// Met à jour les genres sélectionnés. Passer `{}` pour tout effacer.
  ///
  /// Le filtrage est appliqué immédiatement via [DiscoverState.displayResults],
  /// sans déclencher d'appel réseau.
  void setGenres(Set<String> genres) {
    state = state.copyWith(selectedGenres: genres);
  }

  /// Change l'option de tri active.
  ///
  /// Le tri est appliqué immédiatement via [DiscoverState.displayResults],
  /// sans déclencher d'appel réseau.
  void setSortOption(DiscoverSortOption option) {
    state = state.copyWith(sortOption: option);
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
      rawResults: const [],
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
      rawResults: const [],
      clearError: true,
    );

    try {
      final results = await loader();
      // Ignorer si une requête plus récente a été lancée entre-temps.
      if (currentRequest != _requestId) return;
      state = state.copyWith(
        query: query,
        rawResults: results,
        mode: results.isEmpty
            ? DiscoverViewMode.empty
            : DiscoverViewMode.results,
      );
    } catch (error) {
      if (currentRequest != _requestId) return;
      state = state.copyWith(
        query: query,
        rawResults: const [],
        errorMessage: '$error',
        mode: DiscoverViewMode.error,
      );
    }
  }
}
