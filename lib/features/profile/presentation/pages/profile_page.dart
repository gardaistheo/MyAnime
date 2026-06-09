import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../data/repositories/profile_repository.dart';
import '../controllers/profile_controller.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/profile_form.dart';

/// Page de profil utilisateur : photo, prénom, nom, âge.
///
/// Délègue l'affichage de l'avatar à [ProfileAvatar] et le formulaire
/// à [ProfileForm]. La page orchestre uniquement les interactions
/// avec [ProfileController] (lecture/écriture SharedPreferences).
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  /// Ouvre la galerie et met à jour l'avatar du profil.
  Future<void> _pickAvatar(
    BuildContext context,
    WidgetRef ref,
    ProfileData current,
  ) async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (file == null || !context.mounted) return;
    await ref
        .read(profileControllerProvider.notifier)
        .saveProfile(current.copyWith(avatarPath: file.path));
  }

  /// Sauvegarde le profil et affiche une confirmation via SnackBar.
  Future<void> _saveProfile(
    BuildContext context,
    WidgetRef ref,
    ProfileData current,
    String firstName,
    String lastName,
    String age,
  ) async {
    await ref.read(profileControllerProvider.notifier).saveProfile(
          current.copyWith(
            firstName: firstName,
            lastName: lastName,
            age: age,
          ),
        );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profil sauvegardé'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileControllerProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: profileAsync.when(
          data: (profile) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
            child: Column(
              children: [
                Text(
                  'Mon profil',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: AppSpacing.xl),
                ProfileAvatar(
                  profile: profile,
                  onTap: () => _pickAvatar(context, ref, profile),
                ),
                const SizedBox(height: 8),
                Text(
                  'Appuie pour changer la photo',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.white54),
                ),
                const SizedBox(height: AppSpacing.xl),
                ProfileForm(
                  initialData: profile,
                  onSave: (firstName, lastName, age) =>
                      _saveProfile(context, ref, profile, firstName, lastName, age),
                ),
              ],
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Center(
            child: Text('Impossible de charger le profil.'),
          ),
        ),
      ),
    );
  }
}
