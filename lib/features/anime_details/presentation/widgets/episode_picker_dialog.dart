import 'package:flutter/material.dart';

/// Affiche une boîte de dialogue permettant à l'utilisateur de saisir
/// le numéro de l'épisode en cours.
///
/// Retourne le numéro saisi (≥ 0) si l'utilisateur confirme,
/// ou `null` s'il annule.
///
/// La validation en ligne affiche un [errorText] dans le [TextField] si :
/// - la valeur saisie n'est pas un entier valide ou est négative ;
/// - la valeur dépasse [maxEpisodes] (quand celui-ci est connu, > 0).
Future<int?> showEpisodePicker(
  BuildContext context, {
  required int maxEpisodes,
  int? initialEpisode,
}) async {
  final textController = TextEditingController(
    text: (initialEpisode ?? 0).toString(),
  );

  return showDialog<int>(
    context: context,
    builder: (dialogContext) {
      String? errorText;

      return StatefulBuilder(
        builder: (ctx, setState) {
          return AlertDialog(
            title: const Text('Épisode actuel'),
            content: TextField(
              key: const Key('episode_progress_field'),
              controller: textController,
              autofocus: true,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: maxEpisodes > 0
                    ? 'Entre 0 et $maxEpisodes'
                    : 'Numéro d\'épisode',
                errorText: errorText,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () {
                  final parsed = int.tryParse(textController.text.trim());
                  if (parsed == null || parsed < 0) {
                    setState(() => errorText = 'Entrez un numéro valide');
                    return;
                  }
                  if (maxEpisodes > 0 && parsed > maxEpisodes) {
                    setState(
                      () => errorText =
                          'Cet anime n\'a que $maxEpisodes épisodes',
                    );
                    return;
                  }
                  Navigator.of(dialogContext).pop(parsed);
                },
                child: const Text('Enregistrer'),
              ),
            ],
          );
        },
      );
    },
  );
}
