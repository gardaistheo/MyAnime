import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../models/trace_moe_result.dart';

/// Exception levée par [TraceMoeRepository] en cas d'erreur de l'API trace.moe.
class TraceMoeException implements Exception {
  const TraceMoeException(this.message);

  /// Description lisible de l'erreur.
  final String message;

  @override
  String toString() => message;
}

/// Dépôt d'accès à l'API publique [trace.moe](https://trace.moe).
///
/// Permet d'identifier l'anime, l'épisode et le timestamp d'une capture
/// d'écran en envoyant les octets de l'image en POST (`application/octet-stream`).
///
/// trace.moe est une API publique sans clé d'authentification.
/// Limite : images de 25 Mo maximum.
class TraceMoeRepository {
  TraceMoeRepository(this._client);

  final http.Client _client;

  /// Envoie [imageBytes] à trace.moe et retourne les résultats triés par
  /// similarité décroissante.
  ///
  /// Lance une [TraceMoeException] si :
  /// - l'image dépasse 25 Mo ;
  /// - le serveur répond avec un code HTTP ≥ 400 ;
  /// - le champ `error` de la réponse est non vide ;
  /// - aucun résultat n'est trouvé.
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
