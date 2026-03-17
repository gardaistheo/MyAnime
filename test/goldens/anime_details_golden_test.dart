import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:myanime/features/anime_details/presentation/pages/anime_details_page.dart';

import '../helpers/pump_app.dart';

void main() {
  testWidgets('anime details golden', (tester) async {
    await pumpTestWidget(
      tester,
      const AnimeDetailsPage(animeId: 'naruto'),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('anime_details.png'),
    );
  });
}
