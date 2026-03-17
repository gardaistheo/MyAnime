import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:myanime/app/app.dart';

Future<void> pumpMyAnimeApp(
  WidgetTester tester, {
  Size surfaceSize = const Size(390, 844),
}) async {
  tester.view.physicalSize = surfaceSize;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    const ProviderScope(
      child: MyAnimeApp(),
    ),
  );
  await tester.pump();
}

Future<void> pumpTestWidget(
  WidgetTester tester,
  Widget child, {
  Size surfaceSize = const Size(390, 844),
}) async {
  tester.view.physicalSize = surfaceSize;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        themeMode: ThemeMode.dark,
        home: child,
      ),
    ),
  );
  await tester.pump();
}
