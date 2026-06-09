import 'package:shared_preferences/shared_preferences.dart';

class ProfileData {
  const ProfileData({
    this.firstName = '',
    this.lastName = '',
    this.age = '',
    this.avatarPath,
  });

  final String firstName;
  final String lastName;
  final String age;
  final String? avatarPath;

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

class ProfileRepository {
  ProfileRepository(this._prefs);

  static const _firstNameKey = 'profile_firstName';
  static const _lastNameKey = 'profile_lastName';
  static const _ageKey = 'profile_age';
  static const _avatarPathKey = 'profile_avatarPath';

  final SharedPreferencesAsync _prefs;

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
