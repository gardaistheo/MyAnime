import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../shared/models/anime_summary.dart';
import 'library_repository.dart';

class LocalLibraryRepository implements LibraryRepository {
  LocalLibraryRepository(this._preferences);

  static const _storageKey = 'user_library_v1';

  final SharedPreferencesAsync _preferences;

  @override
  Future<List<AnimeSummary>> loadLibrary() async {
    final values = await _preferences.getStringList(_storageKey);
    if (values == null || values.isEmpty) {
      return const [];
    }

    return values
        .map((item) =>
            AnimeSummary.fromJson(jsonDecode(item) as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> saveLibrary(List<AnimeSummary> anime) async {
    final payload = anime.map((item) => jsonEncode(item.toJson())).toList();
    await _preferences.setStringList(_storageKey, payload);
  }
}
