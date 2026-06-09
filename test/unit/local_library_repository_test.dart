import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:myanime/features/library/data/repositories/local_library_repository.dart';
import 'package:myanime/shared/models/anime_summary.dart';

const _naruto = AnimeSummary(
  id: '20',
  title: 'Naruto',
  subtitle: 'Studio Pierrot • 220 ep',
  description: 'Classic ninja shonen.',
  tags: ['Action'],
  episodeCount: 220,
  scoreLabel: '80/100',
  coverImageUrl: '',
  studio: 'Studio Pierrot',
  averageScore: 80,
  siteUrl: 'https://anilist.co/anime/20',
);

const _demonSlayer = AnimeSummary(
  id: '101922',
  title: 'Demon Slayer',
  subtitle: 'ufotable • 26 ep',
  description: 'Slay demons.',
  tags: ['Action'],
  episodeCount: 26,
  scoreLabel: '84/100',
  coverImageUrl: '',
  studio: 'ufotable',
  averageScore: 84,
  siteUrl: 'https://anilist.co/anime/101922',
);

LocalLibraryRepository _makeRepo() =>
    LocalLibraryRepository(SharedPreferencesAsync());

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  test('loadLibrary returns empty list when nothing is stored', () async {
    final result = await _makeRepo().loadLibrary();
    expect(result, isEmpty);
  });

  test('saveLibrary persists anime and loadLibrary restores them', () async {
    final repo = _makeRepo();
    await repo.saveLibrary([_naruto, _demonSlayer]);
    final result = await repo.loadLibrary();

    expect(result, hasLength(2));
    expect(result.map((a) => a.id), containsAll(['20', '101922']));
  });

  test('saveLibrary overwrites previous data', () async {
    final repo = _makeRepo();
    await repo.saveLibrary([_naruto, _demonSlayer]);
    await repo.saveLibrary([_naruto]);
    final result = await repo.loadLibrary();

    expect(result, hasLength(1));
    expect(result.first.id, '20');
  });

  test('saveLibrary with empty list clears stored data', () async {
    final repo = _makeRepo();
    await repo.saveLibrary([_naruto]);
    await repo.saveLibrary([]);
    final result = await repo.loadLibrary();

    expect(result, isEmpty);
  });

  test('persists currentEpisode progress', () async {
    final repo = _makeRepo();
    final narutoWithProgress = _naruto.copyWith(currentEpisode: 42);
    await repo.saveLibrary([narutoWithProgress]);
    final result = await repo.loadLibrary();

    expect(result.first.currentEpisode, 42);
  });
}
