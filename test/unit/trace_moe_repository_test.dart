import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:myanime/features/screen/data/repositories/trace_moe_repository.dart';

final _minimalPng = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+yqZ0AAAAASUVORK5CYII=',
);

Map<String, dynamic> _buildResult({
  int anilistId = 1,
  String filename = 'ep1.mp4',
  double similarity = 0.95,
  double from = 10.0,
  double to = 12.0,
  double at = 11.0,
  bool isAdult = false,
}) =>
    {
      'anilist': {
        'id': anilistId,
        'title': {'romaji': 'Test Anime'},
        'isAdult': isAdult,
      },
      'filename': filename,
      'episode': 1,
      'from': from,
      'to': to,
      'at': at,
      'similarity': similarity,
      'image': '',
      'video': '',
    };

void main() {
  group('TraceMoeRepository', () {
    test('returns results on successful response', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'frameCount': 1,
            'error': '',
            'result': [_buildResult()],
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });
      final repo = TraceMoeRepository(client);

      final results = await repo.identifyAnime(_minimalPng);

      expect(results, hasLength(1));
      expect(results.first.similarity, closeTo(0.95, 0.001));
    });

    test('throws TraceMoeException when result list is empty', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({'frameCount': 0, 'error': '', 'result': []}),
          200,
          headers: {'content-type': 'application/json'},
        );
      });
      final repo = TraceMoeRepository(client);

      expect(
        () => repo.identifyAnime(_minimalPng),
        throwsA(isA<TraceMoeException>()),
      );
    });

    test('throws TraceMoeException on HTTP 4xx with error message', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({'error': 'Too many requests'}),
          429,
          headers: {'content-type': 'application/json'},
        );
      });
      final repo = TraceMoeRepository(client);

      expect(
        () => repo.identifyAnime(_minimalPng),
        throwsA(
          isA<TraceMoeException>().having(
            (e) => e.message,
            'message',
            'Too many requests',
          ),
        ),
      );
    });

    test('throws TraceMoeException when payload contains error field', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({'error': 'Rate limit exceeded', 'result': []}),
          200,
          headers: {'content-type': 'application/json'},
        );
      });
      final repo = TraceMoeRepository(client);

      expect(
        () => repo.identifyAnime(_minimalPng),
        throwsA(isA<TraceMoeException>()),
      );
    });

    test('throws TraceMoeException when image exceeds 25MB', () {
      final client = MockClient((_) async => http.Response('', 200));
      final repo = TraceMoeRepository(client);
      final bigImage = Uint8List(26 * 1024 * 1024);

      expect(
        () => repo.identifyAnime(bigImage),
        throwsA(isA<TraceMoeException>()),
      );
    });
  });
}
