import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../models/trace_moe_result.dart';

class TraceMoeException implements Exception {
  const TraceMoeException(this.message);

  final String message;

  @override
  String toString() => message;
}

class TraceMoeRepository {
  TraceMoeRepository(this._client);

  final http.Client _client;

  Future<List<TraceMoeResult>> identifyAnime(Uint8List imageBytes) async {
    if (imageBytes.lengthInBytes > 25 * 1024 * 1024) {
      throw const TraceMoeException(
          'Image trop lourde. La limite trace.moe est 25MB.');
    }

    final uri = Uri.parse(
      'https://api.trace.moe/search?anilistInfo&cutBorders',
    );

    final response = await _client.post(
      uri,
      headers: const {
        'Content-Type': 'application/octet-stream',
      },
      body: imageBytes,
    );

    if (response.statusCode >= 400) {
      final body = _decodeBody(response.bodyBytes);
      final payload =
          body.isNotEmpty ? jsonDecode(body) as Map<String, dynamic> : null;
      final error = payload?['error'] as String?;

      throw TraceMoeException(
        error?.isNotEmpty == true
            ? error!
            : 'trace.moe a répondu ${response.statusCode}.',
      );
    }

    final payload =
        jsonDecode(_decodeBody(response.bodyBytes)) as Map<String, dynamic>;
    final error = payload['error'] as String? ?? '';
    if (error.isNotEmpty) {
      throw TraceMoeException(error);
    }

    final results = (payload['result'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(TraceMoeResult.fromJson)
        .toList();

    if (results.isEmpty) {
      throw const TraceMoeException('Aucun résultat trouvé.');
    }

    return results;
  }

  String _decodeBody(List<int> bytes) => utf8.decode(bytes);
}
