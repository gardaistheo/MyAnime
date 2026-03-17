import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:myanime/features/screen/data/models/trace_moe_result.dart';
import 'package:myanime/features/screen/data/repositories/trace_moe_repository.dart';
import 'package:myanime/features/screen/data/services/screen_image_picker.dart';
import 'package:myanime/features/screen/presentation/controllers/screen_controller.dart';
import 'package:myanime/features/screen/presentation/pages/screen_search_page.dart';

class _FakeTraceMoeRepository implements TraceMoeRepository {
  _FakeTraceMoeRepository(this.handler);

  final Future<List<TraceMoeResult>> Function(Uint8List) handler;

  @override
  Future<List<TraceMoeResult>> identifyAnime(Uint8List imageBytes) {
    return handler(imageBytes);
  }
}

class _FakePicker implements ScreenImagePicker {
  _FakePicker(this.image);

  final Uint8List image;

  @override
  Future<Uint8List?> pickScreenshot() async => image;
}

final _sampleBytes = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+yqZ0AAAAASUVORK5CYII=',
);
final _sampleResult = TraceMoeResult(
  anilistId: 42,
  title: 'Naruto',
  episode: 140,
  similarity: 0.942,
  from: 120.5,
  to: 122.0,
  at: 121.25,
  previewImageUrl: '',
  previewVideoUrl: '',
  filename: 'Naruto - Episode 1',
  isAdult: false,
);

Future<void> _pumpScreenSearchPage(
  WidgetTester tester, {
  dynamic overrides = const [],
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(overrides.isEmpty
      ? const ProviderScope(
          child: MaterialApp(
            themeMode: ThemeMode.dark,
            home: ScreenSearchPage(),
          ),
        )
      : ProviderScope(
          overrides: overrides,
          child: const MaterialApp(
            themeMode: ThemeMode.dark,
            home: ScreenSearchPage(),
          ),
        ));
  await tester.pump();
}

void main() {
  testWidgets('Screen page shows idle state before any screenshot',
      (tester) async {
    await _pumpScreenSearchPage(tester);

    expect(find.byKey(const Key('screen_idle_state')), findsOneWidget);
    expect(find.text('Choisir un screenshot'), findsOneWidget);
  });

  testWidgets('Screen page displays results after trace.moe returns matches',
      (tester) async {
    await _pumpScreenSearchPage(
      tester,
      overrides: [
        screenImagePickerProvider.overrideWithValue(_FakePicker(_sampleBytes)),
        traceMoeRepositoryProvider.overrideWithValue(
          _FakeTraceMoeRepository((_) async => [_sampleResult]),
        ),
      ],
    );

    await tester.tap(find.text('Choisir un screenshot'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('screen_results_state')), findsOneWidget);
    expect(find.text('Meilleur match'), findsOneWidget);
    expect(find.text('Naruto'), findsAtLeastNWidgets(1));
  });

  testWidgets('Screen page surfaces an error if trace.moe fails',
      (tester) async {
    await _pumpScreenSearchPage(
      tester,
      overrides: [
        screenImagePickerProvider.overrideWithValue(_FakePicker(_sampleBytes)),
        traceMoeRepositoryProvider.overrideWithValue(
          _FakeTraceMoeRepository(
              (_) async => throw const TraceMoeException('Nope')),
        ),
      ],
    );

    await tester.tap(find.text('Choisir un screenshot'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('screen_error_state')), findsOneWidget);
    expect(find.text('Erreur inconnue.'), findsNothing);
    expect(find.text('Nope'), findsOneWidget);
  });
}
