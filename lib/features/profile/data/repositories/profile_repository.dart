import 'package:shared_preferences/shared_preferences.dart';

/// Données du profil utilisateur.
///
/// Objet valeur immuable. Toutes les chaînes sont vides par défaut
/// (pas de `null` pour les champs texte, facilitant le binding avec
/// les [TextEditingController]).
class ProfileData {
  const ProfileData({
    this.firstName = '',
    this.lastName = '',
    this.age = '',
    this.avatarPath,
  });

  /// Prénom de l'utilisateur.
  final String firstName;

  /// Nom de famille de l'utilisateur.
  final String lastName;

  /// Âge de l'utilisateur (stocké en chaîne pour simplifier la saisie).
  final String age;

  /// Chemin absolu vers la photo de profil sur le disque local, ou `null`.
  ///
  /// La photo est sélectionnée depuis la galerie via [ImagePicker] et
  /// copiée dans le répertoire de données de l'app.
  final String? avatarPath;

  /// Retourne une copie avec les champs surchargés.
  ///
  /// [clearAvatar] met [avatarPath] à `null` (suppression de la photo).
  ProfileData copyWith({
    String? firstName,
    String? lastName,
    String? age,
    String? avatarPath,
    bool clearAvatar = false,
  }) {
    return ProfileData(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      age: age ?? this.age,
      avatarPath: clearAvatar ? null : (avatarPath ?? this.avatarPath),
    );
  }
}

/// Dépôt de persistance du profil utilisateur via SharedPreferences.
///
/// Chaque champ est stocké sous une clé dédiée (préfixe `profile_`)
/// pour permettre des lectures/écritures indépendantes.
class ProfileRepository {
  ProfileRepository(this._prefs);

  static const _firstNameKey = 'profile_firstName';
  static const _lastNameKey = 'profile_lastName';
  static const _ageKey = 'profile_age';
  static const _avatarPathKey = 'profile_avatarPath';

  final SharedPreferencesAsync _prefs;

  /// Charge le profil depuis SharedPreferences.
  ///
  /// Retourne un [ProfileData] avec des valeurs vides si aucun profil n'est
  /// encore enregistré.
  Future<ProfileData> loadProfile() async {
    final firstName = await _prefs.getString(_firstNameKey) ?? '';
    final lastName = await _prefs.getString(_lastNameKey) ?? '';
    final age = await _prefs.getString(_ageKey) ?? '';
    final avatarPath = await _prefs.getString(_avatarPathKey);
    return ProfileData(
        firstName: firstName,
        lastName: lastName,
        age: age,
        avatarPath: avatarPath);
  }

  /// Persiste [data] dans SharedPreferences.
  ///
  /// Si [ProfileData.avatarPath] est `null`, la clé correspondante est
  /// supprimée (pour ne pas laisser un chemin périmé après suppression).
  Future<void> saveProfile(ProfileData data) async {
    await _prefs.setString(_firstNameKey, data.firstName);
    await _prefs.setString(_lastNameKey, data.lastName);
    await _prefs.setString(_ageKey, data.age);
    if (data.avatarPath != null) {
      await _prefs.setString(_avatarPathKey, data.avatarPath!);
    } else {
      await _prefs.remove(_avatarPathKey);
    }
  }
}
