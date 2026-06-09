import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/repositories.dart';
import '../../data/repositories/profile_repository.dart';

/// Provider du controller de profil utilisateur.
final profileControllerProvider =
    AsyncNotifierProvider<ProfileController, ProfileData>(
  ProfileController.new,
);

/// Gestionnaire d'état du profil utilisateur (prénom, nom, âge, avatar).
///
/// Charge les données depuis [ProfileRepository] au démarrage. La méthode
/// [saveProfile] met à jour l'état de façon optimiste (UI instantanée) puis
/// persiste en arrière-plan.
class ProfileController extends AsyncNotifier<ProfileData> {
  @override
  Future<ProfileData> build() {
    return ref.read(profileRepositoryProvider).loadProfile();
  }

  /// Sauvegarde [data] en mémoire immédiatement, puis persiste via [ProfileRepository].
  ///
  /// L'état est mis à jour avant la fin de la persistance pour une
  /// réactivité maximale de l'interface.
  Future<void> saveProfile(ProfileData data) async {
    state = AsyncData(data);
    await ref.read(profileRepositoryProvider).saveProfile(data);
  }
}
