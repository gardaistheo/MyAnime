import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:myanime/features/anime/data/services/anilist_graphql_client.dart';

void main() {
  group('AniListGraphqlClient', () {
    test('returns data map on 200 response', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'data': {'Page': <String, dynamic>{}},
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });
      final graphqlClient = AniListGraphqlClient(client);

      final result = await graphqlClient.query('{ Page { media { id } } }');

      expect(result, {'Page': <String, dynamic>{}});
    });

    test('throws AniListException on HTTP 4xx', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'errors': [
              {'message': 'Not Found'},
            ],
          }),
          404,
          headers: {'content-type': 'application/json'},
        );
      });
      final graphqlClient = AniListGraphqlClient(client);

      expect(
        () => graphqlClient.query('{ Page { media { id } } }'),
        throwsA(
          isA<AniListException>().having(
            (e) => e.message,
            'message',
            'Not Found',
          ),
        ),
      );
    });

    test('throws AniListException on GraphQL errors in 200 response', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'data': null,
            'errors': [
              {'message': 'Field not found'},
            ],
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });
      final graphqlClient = AniListGraphqlClient(client);

      expect(
        () => graphqlClient.query('{ bad }'),
        throwsA(isA<AniListException>()),
      );
    });

    test('sends variables in request body', () async {
      late Map<String, dynamic> capturedBody;

      final client = MockClient((request) async {
        capturedBody =
            jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response(
          jsonEncode({'data': <String, dynamic>{}}),
          200,
          headers: {'content-type': 'application/json'},
        );
      });
      final graphqlClient = AniListGraphqlClient(client);

      await graphqlClient.query(
        'query (\$id: Int) { Media(id: \$id) { id } }',
        variables: {'id': 42},
      );

      expect(capturedBody['variables'], {'id': 42});
    });

    test('uses the AniList GraphQL endpoint', () async {
      late Uri capturedUri;

      final client = MockClient((request) async {
        capturedUri = request.url;
        return http.Response(
          jsonEncode({'data': <String, dynamic>{}}),
          200,
          headers: {'content-type': 'application/json'},
        );
      });
      final graphqlClient = AniListGraphqlClient(client);

      await graphqlClient.query('{ Page { media { id } } }');

      expect(capturedUri.host, 'graphql.anilist.co');
    });
  });
}
