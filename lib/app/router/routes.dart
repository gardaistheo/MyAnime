class AppRoutes {
  const AppRoutes._();

  static const list = '/list';
  static const discover = '/discover';
  static const screen = '/screen';
  static const news = '/news';
  static const profile = '/profile';

  static const listName = 'list';
  static const discoverName = 'discover';
  static const screenName = 'screen';
  static const newsName = 'news';
  static const profileName = 'profile';
  static const animeDetailsName = 'animeDetails';

  static const animeDetailsPath = 'anime/:id';

  static String animeDetailsLocation(String animeId) =>
      '$discover/anime/$animeId';
}
