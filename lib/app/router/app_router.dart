import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/anime_details/presentation/pages/anime_details_page.dart';
import '../../features/discover/presentation/pages/discover_page.dart';
import '../../features/screen/presentation/pages/screen_search_page.dart';
import '../../features/placeholder/presentation/pages/placeholder_tab_page.dart';
import '../../shared/widgets/anime_app_shell.dart';
import 'routes.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.discover,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AnimeAppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.list,
                name: AppRoutes.listName,
                builder: (context, state) => const PlaceholderTabPage(
                  title: 'Liste',
                  subtitle:
                      'Ta bibliothèque arrivera quand tu m’enverras son écran.',
                  icon: Icons.video_library_rounded,
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.discover,
                name: AppRoutes.discoverName,
                builder: (context, state) => const DiscoverPage(),
                routes: [
                  GoRoute(
                    path: 'anime/:id',
                    name: AppRoutes.animeDetailsName,
                    builder: (context, state) {
                      final animeId = state.pathParameters['id']!;
                      return AnimeDetailsPage(animeId: animeId);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.screen,
                name: AppRoutes.screenName,
                builder: (context, state) => const ScreenSearchPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.news,
                name: AppRoutes.newsName,
                builder: (context, state) => const PlaceholderTabPage(
                  title: 'News',
                  subtitle:
                      'Les actus anime auront un vrai écran quand tu le donneras.',
                  icon: Icons.article_rounded,
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                name: AppRoutes.profileName,
                builder: (context, state) => const PlaceholderTabPage(
                  title: 'User',
                  subtitle:
                      'Le profil reste volontairement minimal pour cette V1.',
                  icon: Icons.person_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
