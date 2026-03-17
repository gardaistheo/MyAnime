import 'dart:convert';

import 'package:http/http.dart' as http;

class AniListException implements Exception {
  const AniListException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AniListGraphqlClient {
  AniListGraphqlClient(this._client);

  final http.Client _client;

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
