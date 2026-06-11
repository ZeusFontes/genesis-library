// frontend/lib/screens/home/home_movies_screen.dart
//
// F1: Seção "Domínio Público" como primeira seção após o banner (cards com badge "🎬 Grátis").
// F3: Prateleiras na ordem: Banner → Domínio Público → Em Alta → Mais Bem Avaliados.
//     Remove "Destaques da Semana".
// F2: "Em Alta" usa endpoint /trending que agora retorna clássicos via discover/movie.

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../core/constants/routes.dart';
import '../../models/media_content.dart';
import '../../services/api_service.dart';
import '../../widgets/hero_banner.dart';
import '../../widgets/horizontal_shelf.dart';

class HomeMoviesScreen extends StatefulWidget {
  const HomeMoviesScreen({super.key});

  @override
  State<HomeMoviesScreen> createState() => _HomeMoviesScreenState();
}

class _HomeMoviesScreenState extends State<HomeMoviesScreen> {
  late Future<List<MediaContent>> _trendingFuture;
  late Future<List<MediaContent>> _publicDomainFuture;
  late Future<List<MediaContent>> _topRatedFuture;

  @override
  void initState() {
    super.initState();
    _trendingFuture = _loadTrending();
    _publicDomainFuture = _loadPublicDomain();
    _topRatedFuture = _loadTopRated();
  }

  Future<List<MediaContent>> _loadTrending() async {
    final raw = await ApiService.fetchTrendingMovies();
    return raw.map(_mapToMediaContent).toList();
  }

  Future<List<MediaContent>> _loadPublicDomain() async {
    final raw = await ApiService.fetchPublicDomainMovies(
        q: 'silent film classic 1920s');
    return raw.map(_mapToMediaContent).toList();
  }

  Future<List<MediaContent>> _loadTopRated() async {
    final raw = await ApiService.fetchTopRatedMovies();
    return raw.map(_mapToMediaContent).toList();
  }

  MediaContent _mapToMediaContent(Map<String, dynamic> m) {
    return MediaContent(
      id: (m['imdb_id'] as String?) ??
          (m['id'] as String?) ??
          m['tmdb_id'].toString(),
      title: (m['title'] as String?) ?? '',
      poster: (m['poster_url'] as String?) ?? '',
      backdrop: (m['backdrop_url'] as String?) ?? '',
      synopsis: (m['overview'] as String?) ?? '',
      publicDomain: (m['public_domain'] as bool?) ?? false,
      externalLink: (m['streaming_link'] as String?),
      streamingName: (m['streaming_name'] as String?),
      imdb: (m['imdb_score'] as num?)?.toDouble() ??
          (m['vote_average'] as num?)?.toDouble() ??
          0.0,
      rottenTomatoes: (m['rt_score'] as int?),
      genre: '',
      year: _parseYear(m['release_date'] as String?),
      cast: const [],
    );
  }

  int? _parseYear(String? date) {
    if (date == null || date.length < 4) return null;
    return int.tryParse(date.substring(0, 4));
  }

  void _goToDetail(BuildContext context, MediaContent item) {
    Navigator.pushNamed(context, AppRoutes.movieDetail, arguments: item);
  }

  void _reload() {
    setState(() {
      _trendingFuture = _loadTrending();
      _publicDomainFuture = _loadPublicDomain();
      _topRatedFuture = _loadTopRated();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MediaContent>>(
      future: _trendingFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.wifi_off, size: 48, color: Colors.grey),
                const SizedBox(height: 12),
                Text(
                  'Não foi possível carregar os filmes.\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _reload,
                  child: const Text('Tentar novamente'),
                ),
              ],
            ),
          );
        }

        final movies = snapshot.data ?? [];
        final bannerItems = movies.take(3).toList();

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Banner carousel
              if (bannerItems.isNotEmpty)
                CarouselSlider(
                  options: CarouselOptions(
                    height: 380,
                    autoPlay: true,
                    autoPlayInterval: const Duration(seconds: 6),
                    viewportFraction: 1.0,
                  ),
                  items: bannerItems.map((item) {
                    return HeroBanner(
                      content: item,
                      onWatch: () => _goToDetail(context, item),
                      onDetails: () => _goToDetail(context, item),
                    );
                  }).toList(),
                ),

              const SizedBox(height: 24),

              // 2. Domínio Público — primeira após o banner (F1, F3)
              FutureBuilder<List<MediaContent>>(
                future: _publicDomainFuture,
                builder: (ctx, pdSnap) {
                  if (pdSnap.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final pdMovies = pdSnap.data ?? [];
                  if (pdMovies.isEmpty) return const SizedBox();
                  return HorizontalShelf(
                    title: 'Domínio Público',
                    items: pdMovies,
                    onItemTap: (item) => _goToDetail(context, item),
                  );
                },
              ),

              // 3. Em Alta — clássicos via discover (F2, F3)
              HorizontalShelf(
                title: 'Em Alta',
                items: movies,
                onItemTap: (item) => _goToDetail(context, item),
              ),

              // 4. Mais Bem Avaliados (F3)
              FutureBuilder<List<MediaContent>>(
                future: _topRatedFuture,
                builder: (ctx, trSnap) {
                  if (trSnap.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final trMovies = trSnap.data ?? [];
                  if (trMovies.isEmpty) return const SizedBox();
                  return HorizontalShelf(
                    title: '⭐ Mais Bem Avaliados',
                    items: trMovies,
                    onItemTap: (item) => _goToDetail(context, item),
                  );
                },
              ),

              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}
