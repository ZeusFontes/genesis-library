class MediaContent {
  final String id;
  final String title;
  final String poster;
  final String backdrop;
  final String synopsis;
  final bool publicDomain;
  final String? externalLink;
  final String? streamingName;
  final double imdb;
  final int? rottenTomatoes;
  final String genre;
  final int? year;
  final List<String> cast;

  MediaContent({
    required this.id,
    required this.title,
    this.poster = '',
    this.backdrop = '',
    this.synopsis = '',
    required this.publicDomain,
    this.externalLink,
    this.streamingName,
    this.imdb = 0.0,
    this.rottenTomatoes,
    this.genre = '',
    this.year,
    this.cast = const [],
  });

  // Este é o método fundamental para o app entender o backend
  factory MediaContent.fromJson(Map<String, dynamic> json) {
    return MediaContent(
      id: json['tmdb_id']?.toString() ?? '',
      title: json['title'] ?? 'Sem título',
      poster: json['poster_url'] ?? '',
      backdrop: json['backdrop_url'] ?? '',
      synopsis: json['overview'] ?? '',
      // Se não vier do backend, assumimos false por segurança
      publicDomain: json['public_domain'] ?? false,
      // Mapeamento dos novos campos de streaming
      externalLink: json['streaming_link'],
      streamingName: json['streaming_name'],
      imdb: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      rottenTomatoes: json['rotten_tomatoes'],
      genre: json['genre'] ?? '',
      year: json['year'],
      // Converte a lista de elenco com segurança
      cast:
          (json['cast'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
              [],
    );
  }
}
