import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../shared/models/anime_summary.dart';
import 'library_repository.dart';

/// Implémentation de [LibraryRepository] utilisant SharedPreferences.
///
/// La bibliothèque est stockée sous la clé [_storageKey] sous la forme
/// d'une liste de chaînes JSON, chacune étant un [AnimeSummary] sérialisé
/// via [AnimeSummary.toJson].
///
/// La clé inclut un suffixe de version (`_v1`) pour permettre des migrations
/// futures sans perte de données.
class LocalLibraryRepository implements LibraryRepository {
  LocalLibraryRepository(this._preferences);

  /// Clé SharedPreferences versionnée pour la liste de la bibliothèque.
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
