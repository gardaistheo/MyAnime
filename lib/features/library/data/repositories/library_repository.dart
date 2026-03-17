import '../../../../shared/models/anime_summary.dart';

abstract class LibraryRepository {
  Future<List<AnimeSummary>> loadLibrary();

  Future<void> saveLibrary(List<AnimeSummary> anime);
}
