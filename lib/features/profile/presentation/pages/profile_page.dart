import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../data/repositories/profile_repository.dart';
import '../controllers/profile_controller.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  late final TextEditingController _firstNameCtrl;
  late final TextEditingController _lastNameCtrl;
  late final TextEditingController _ageCtrl;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _firstNameCtrl = TextEditingController();
    _lastNameCtrl = TextEditingController();
    _ageCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _ageCtrl.dispose();
    super.dispose();
  }

  void _syncControllers(ProfileData data) {
    if (_loaded) return;
    _loaded = true;
    _firstNameCtrl.text = data.firstName;
    _lastNameCtrl.text = data.lastName;
    _ageCtrl.text = data.age;
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (file == null || !mounted) return;
    final current =
        ref.read(profileControllerProvider).asData?.value ?? const ProfileData();
    await ref
        .read(profileControllerProvider.notifier)
        .saveProfile(current.copyWith(avatarPath: file.path));
  }

  Future<void> _save() async {
    final current =
        ref.read(profileControllerProvider).asData?.value ?? const ProfileData();
    await ref.read(profileControllerProvider.notifier).saveProfile(
          current.copyWith(
            firstName: _firstNameCtrl.text.trim(),
            lastName: _lastNameCtrl.text.trim(),
            age: _ageCtrl.text.trim(),
          ),
        );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profil sauvegardé'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileControllerProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: profileAsync.when(
          data: (profile) {
            _syncControllers(profile);
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
              child: Column(
                children: [
                  // Titre
                  Text(
                    'Mon profil',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Avatar
                  GestureDetector(
                    onTap: _pickAvatar,
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.accent.withValues(alpha: 0.4),
                              width: 3,
                            ),
                          ),
                          // ClipOval garantit un découpage circulaire parfait,
                          // sans laisser la couleur de fond visible en périphérie.
                          child: ClipOval(
                            child: profile.avatarPath != null
                                ? Image.file(
                                    File(profile.avatarPath!),
                                    width: 110,
                                    height: 110,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) =>
                                        _AvatarFallback(profile: profile),
                                  )
                                : _AvatarFallback(profile: profile),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.backgroundBottom,
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Appuie pour changer la photo',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors.textMuted),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Champs
                  _ProfileField(
                    controller: _firstNameCtrl,
                    label: 'Prénom',
                    icon: Icons.person_outline_rounded,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _ProfileField(
                    controller: _lastNameCtrl,
                    label: 'Nom',
                    icon: Icons.badge_outlined,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _ProfileField(
                    controller: _ageCtrl,
                    label: 'Âge',
                    icon: Icons.cake_outlined,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Bouton sauvegarder
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.save_rounded),
                      label: const Text(
                        'Sauvegarder',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: _save,
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Center(
            child: Text('Impossible de charger le profil.'),
          ),
        ),
      ),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback({required this.profile});

  final ProfileData profile;

  @override
  Widget build(BuildContext context) {
    final initials = _initials(profile);
    return Container(
      color: AppColors.surfaceMuted,
      child: Center(
        child: initials.isNotEmpty
            ? Text(
                initials,
                style: Theme.of(context)
                    .textTheme
                    .headlineLarge
                    ?.copyWith(color: AppColors.textSecondary),
              )
            : const Icon(Icons.person_rounded,
                size: 52, color: AppColors.textMuted),
      ),
    );
  }

  String _initials(ProfileData p) {
    final parts = [
      p.firstName.isNotEmpty ? p.firstName[0] : '',
      p.lastName.isNotEmpty ? p.lastName[0] : '',
    ].where((s) => s.isNotEmpty).toList();
    return parts.join().toUpperCase();
  }
}

class _ProfileField extends StatelessWidget {
  const _ProfileField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType = TextInputType.text,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType keyboardType;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: Theme.of(context).textTheme.bodyLarge,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.textMuted, size: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadii.lg),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
