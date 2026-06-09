import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_radii.dart';
import '../../../../../app/theme/app_spacing.dart';
import '../../data/repositories/profile_repository.dart';

/// Formulaire de modification du profil : prénom, nom, âge et bouton Sauvegarder.
///
/// Possède ses propres [TextEditingController] initialisés une seule fois
/// depuis [initialData]. Appelle [onSave] avec les valeurs saisies lors de
/// la confirmation, sans réinitialiser les champs si le profil parent change
/// (ex. changement de photo).
class ProfileForm extends StatefulWidget {
  const ProfileForm({
    super.key,
    required this.initialData,
    required this.onSave,
  });

  /// Valeurs initiales des champs (chargées depuis SharedPreferences).
  final ProfileData initialData;

  /// Appelé avec (prénom, nom, âge) quand l'utilisateur confirme.
  final Future<void> Function(String firstName, String lastName, String age)
      onSave;

  @override
  State<ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  late final TextEditingController _firstNameCtrl;
  late final TextEditingController _lastNameCtrl;
  late final TextEditingController _ageCtrl;

  @override
  void initState() {
    super.initState();
    // Initialisation unique depuis les données persistées
    _firstNameCtrl =
        TextEditingController(text: widget.initialData.firstName);
    _lastNameCtrl =
        TextEditingController(text: widget.initialData.lastName);
    _ageCtrl = TextEditingController(text: widget.initialData.age);
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _ageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: const Icon(Icons.save_rounded),
            label: const Text(
              'Sauvegarder',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            onPressed: () => widget.onSave(
              _firstNameCtrl.text.trim(),
              _lastNameCtrl.text.trim(),
              _ageCtrl.text.trim(),
            ),
          ),
        ),
      ],
    );
  }
}

/// Champ de saisie stylisé avec icône préfixe et fond arrondi.
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
