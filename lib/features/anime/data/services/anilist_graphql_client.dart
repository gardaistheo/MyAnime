import 'dart:convert';

import 'package:http/http.dart' as http;

/// Exception levée par [AniListGraphqlClient] en cas d'erreur de l'API AniList.
///
/// Le champ [message] contient soit le message d'erreur retourné par l'API,
/// soit un message générique indiquant le code HTTP reçu.
class AniListException implements Exception {
  const AniListException(this.message);

  /// Description lisible de l'erreur.
  final String message;

  @override
  String toString() => message;
}

/// Client HTTP bas niveau pour l'API GraphQL publique d'AniList.
///
/// Envoie des requêtes POST à `https://graphql.anilist.co`, parse la réponse
/// JSON et lève une [AniListException] en cas d'erreur HTTP ou d'erreur
/// GraphQL dans le payload.
///
/// Utiliser [AniListAnimeRepository] plutôt que ce client directement :
/// le repository offre une interface métier de plus haut niveau.
class AniListGraphqlClient {
  AniListGraphqlClient(this._client);

  final http.Client _client;

  /// Exécute une requête GraphQL [document] avec des [variables] optionnelles.
  ///
  /// Retourne le champ `data` de la réponse JSON en cas de succès.
  ///
  /// Lance une [AniListException] si :
  /// - le serveur répond avec un code HTTP ≥ 400 ;
  /// - la réponse contient un champ `errors` non vide.
  Future<Map<String, dynamic>> query(
    String document, {
    Map<String, dynamic> variables = const {},
  }) async {
    final response = await _client.post(
      Uri.parse('https://graphql.anilist.co'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'query': document,
        'variables': variables,
      }),
    );

    final payload =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

    if (response.statusCode >= 400) {
      final errors = payload['errors'] as List<dynamic>?;
      final message = errors == null || errors.isEmpty
          ? 'AniList a répondu ${response.statusCode}.'
          : (errors.first as Map<String, dynamic>)['message'] as String? ??
              'AniList a répondu ${response.statusCode}.';
      throw AniListException(message);
    }

    final errors = payload['errors'] as List<dynamic>?;
    if (errors != null && errors.isNotEmpty) {
      final message =
          (errors.first as Map<String, dynamic>)['message'] as String? ??
              'Erreur AniList.';
      throw AniListException(message);
    }

    return payload['data'] as Map<String, dynamic>;
  }
}
