import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../../data/models/trace_moe_result.dart';
import '../../data/repositories/trace_moe_repository.dart';
import '../../data/services/screen_image_picker.dart';

enum ScreenStatus {
  idle,
  picking,
  searching,
  success,
  error,
}

class ScreenState {
  const ScreenState({
    required this.status,
    required this.selectedImage,
    required this.results,
    required this.errorMessage,
  });

  const ScreenState.initial()
      : status = ScreenStatus.idle,
        selectedImage = null,
        results = const [],
        errorMessage = null;

  final ScreenStatus status;
  final Uint8List? selectedImage;
  final List<TraceMoeResult> results;
  final String? errorMessage;

  TraceMoeResult? get topResult => results.isEmpty ? null : results.first;

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

final httpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

final traceMoeRepositoryProvider = Provider<TraceMoeRepository>((ref) {
  return TraceMoeRepository(ref.watch(httpClientProvider));
});

final screenImagePickerProvider = Provider<ScreenImagePicker>((ref) {
  return GalleryScreenImagePicker(ImagePicker());
});

final screenControllerProvider =
    NotifierProvider<ScreenController, ScreenState>(ScreenController.new);

class ScreenController extends Notifier<ScreenState> {
  @override
  ScreenState build() => const ScreenState.initial();

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

  void clear() {
    state = const ScreenState.initial();
  }
}
