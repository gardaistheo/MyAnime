import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../../data/models/trace_moe_result.dart';
import '../../data/repositories/trace_moe_repository.dart';
import '../../data/services/screen_image_picker.dart';

/// Étapes possibles du flux de reconnaissance de screenshot.
enum ScreenStatus {
  /// Aucune action en cours.
  idle,

  /// L'utilisateur est en train de sélectionner une image.
  picking,

  /// La requête trace.moe est en cours.
  searching,

  /// Les résultats ont été reçus avec succès.
  success,

  /// Une erreur est survenue (réseau, image trop lourde, aucun résultat…).
  error,
}

/// État immuable de l'écran de reconnaissance de screenshot.
class ScreenState {
  const ScreenState({
    required this.status,
    required this.selectedImage,
    required this.results,
    required this.errorMessage,
  });

  /// État initial : idle, sans image ni résultats.
  const ScreenState.initial()
      : status = ScreenStatus.idle,
        selectedImage = null,
        results = const [],
        errorMessage = null;

  /// Statut actuel du flux de reconnaissance.
  final ScreenStatus status;

  /// Octets de l'image sélectionnée, ou `null` si aucune image choisie.
  final Uint8List? selectedImage;

  /// Liste des correspondances retournées par trace.moe, triées par similarité.
  final List<TraceMoeResult> results;

  /// Message d'erreur lisible, non nul uniquement si [status] est [ScreenStatus.error].
  final String? errorMessage;

  /// Retourne le meilleur résultat (premier de la liste), ou `null` si vide.
  TraceMoeResult? get topResult => results.isEmpty ? null : results.first;

  /// Retourne une copie avec les champs surchargés.
  ///
  /// [clearError] met [errorMessage] à `null`.
  /// [clearImage] met [selectedImage] à `null`.
  ScreenState copyWith({
    ScreenStatus? status,
    Uint8List? selectedImage,
    List<TraceMoeResult>? results,
    String? errorMessage,
    bool clearError = false,
    bool clearImage = false,
  }) {
    return ScreenState(
      status: status ?? this.status,
      selectedImage: clearImage ? null : (selectedImage ?? this.selectedImage),
      results: results ?? this.results,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// Client HTTP dédié à la feature Screen (distinct du client AniList).
final httpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

/// Provider du dépôt trace.moe.
final traceMoeRepositoryProvider = Provider<TraceMoeRepository>((ref) {
  return TraceMoeRepository(ref.watch(httpClientProvider));
});

/// Provider du service de sélection d'image (galerie).
final screenImagePickerProvider = Provider<ScreenImagePicker>((ref) {
  return GalleryScreenImagePicker(ImagePicker());
});

/// Provider du controller de l'écran Screen.
final screenControllerProvider =
    NotifierProvider<ScreenController, ScreenState>(ScreenController.new);

/// Gestionnaire d'état de la feature Screen (identification de screenshot).
///
/// Orchestre la sélection d'image via [ScreenImagePicker] et l'analyse
/// via [TraceMoeRepository]. Les transitions d'état suivent l'enum [ScreenStatus].
class ScreenController extends Notifier<ScreenState> {
  @override
  ScreenState build() => const ScreenState.initial();

  /// Lance la sélection d'image depuis la galerie, puis analyse immédiatement.
  ///
  /// Si l'utilisateur annule la sélection, l'état repasse à [ScreenStatus.idle].
  Future<void> pickAndAnalyzeScreenshot() async {
    state = state.copyWith(
      status: ScreenStatus.picking,
      clearError: true,
    );

    final imageBytes =
        await ref.read(screenImagePickerProvider).pickScreenshot();
    if (imageBytes == null) {
      state = state.copyWith(status: ScreenStatus.idle);
      return;
    }

    await analyzeScreenshot(imageBytes);
  }

  /// Envoie [imageBytes] à trace.moe et met à jour l'état avec les résultats.
  ///
  /// Peut être appelé directement (ex. depuis les tests) sans passer par
  /// la sélection galerie.
  Future<void> analyzeScreenshot(Uint8List imageBytes) async {
    state = state.copyWith(
      status: ScreenStatus.searching,
      selectedImage: imageBytes,
      results: const [],
      clearError: true,
    );

    try {
      final results =
          await ref.read(traceMoeRepositoryProvider).identifyAnime(imageBytes);
      state = state.copyWith(
        status: ScreenStatus.success,
        selectedImage: imageBytes,
        results: results,
      );
    } on TraceMoeException catch (error) {
      state = state.copyWith(
        status: ScreenStatus.error,
        selectedImage: imageBytes,
        results: const [],
        errorMessage: error.message,
      );
    } catch (error) {
      state = state.copyWith(
        status: ScreenStatus.error,
        selectedImage: imageBytes,
        results: const [],
        errorMessage: 'Erreur inattendue: $error',
      );
    }
  }

  /// Réinitialise l'écran à son état initial.
  void clear() {
    state = const ScreenState.initial();
  }
}
