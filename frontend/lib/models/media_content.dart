class MediaContent {
  final String id;
  final String title;
  final String poster;
  final String backdrop;
  final String synopsis;
  final bool publicDomain;
  final String? externalLink;
  final double imdb;
  final double rottenTomatoes;
  final String genre;
  final int? year;
  final List<String> cast;

  MediaContent({
    required this.id,
    required this.title,
    required this.poster,
    required this.backdrop,
    required this.synopsis,
    required this.publicDomain,
    this.externalLink,
    required this.imdb,
    required this.rottenTomatoes,
    required this.genre,
    this.year,
    this.cast = const [],
  });
}
