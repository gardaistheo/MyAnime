import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/repositories.dart';
import '../../data/repositories/profile_repository.dart';

final profileControllerProvider =
    AsyncNotifierProvider<ProfileController, ProfileData>(
  ProfileController.new,
);

class ProfileController extends AsyncNotifier<ProfileData> {
  @override
  Future<ProfileData> build() {
    return ref.read(profileRepositoryProvider).loadProfile();
  }

  Future<void> saveProfile(ProfileData data) async {
    state = AsyncData(data);
    await ref.read(profileRepositoryProvider).saveProfile(data);
  }
}
