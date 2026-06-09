import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../data/repositories/profile_repository.dart';

/// Avatar circulaire cliquable avec badge caméra.
///
/// Affiche la photo de profil depuis [ProfileData.avatarPath] si disponible,
/// sinon les initiales de l'utilisateur via [_AvatarFallback].
/// Appelle [onTap] pour déclencher la sélection d'une nouvelle photo.
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.profile,
    required this.onTap,
  });

  /// Données du profil (chemin de la photo + prénom/nom pour les initiales).
  final ProfileData profile;

  /// Appelé quand l'utilisateur appuie sur l'avatar.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
          // Badge caméra positionné en bas à droite
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
    );
  }
}

/// Fallback affiché quand aucune photo n'est définie.
///
/// Montre les initiales prénom + nom, ou une icône personne si le profil est vide.
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
            : const Icon(
                Icons.person_rounded,
                size: 52,
                color: AppColors.textMuted,
              ),
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
