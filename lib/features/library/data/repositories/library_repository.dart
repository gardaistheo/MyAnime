import '../../../../shared/models/anime_summary.dart';

/// Contrat de persistance de la bibliothèque utilisateur.
///
/// Cette interface isole la logique de stockage de la couche présentation.
/// L'implémentation concrète est [LocalLibraryRepository] qui utilise
/// SharedPreferences. Une implémentation en mémoire peut être injectée
/// dans les tests.
abstract class LibraryRepository {
  /// Charge la liste des animes sauvegardés par l'utilisateur.
  ///
  /// Retourne une liste vide si la bibliothèque n'existe pas encore.
  Future<List<AnimeSummary>> loadLibrary();

  /// Remplace la bibliothèque persistée par la liste [anime] fournie.
  ///
  /// Appelé à chaque modification (ajout, suppression, mise à jour de progression).
  Future<void> saveLibrary(List<AnimeSummary> anime);
}
