import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../core/constants/routes.dart';
import '../../models/media_content.dart';
import '../../services/api_service.dart';
import '../../widgets/hero_banner.dart';
import '../../widgets/horizontal_shelf.dart';

class HomeSeriesScreen extends StatefulWidget {
  const HomeSeriesScreen({super.key});

  @override
  State<HomeSeriesScreen> createState() => _HomeSeriesScreenState();
}

class _HomeSeriesScreenState extends State<HomeSeriesScreen> {
  // Múltiplos futures para carregar as prateleiras de forma independente
  late Future<List<MediaContent>> _trendingFuture;
  late Future<List<MediaContent>> _scifiFuture;
  late Future<List<MediaContent>> _investigationFuture;
  late Future<List<MediaContent>> _fantasyFuture;

  @override
  void initState() {
    super.initState();
    _loadAllCatalogs();
  }

  void _loadAllCatalogs() {
    _trendingFuture = _loadTrendingSeries();

    // Usando o endpoint de search com palavras-chave para criar prateleiras temáticas
    _scifiFuture =
        _searchSeriesCategory('Star'); // Puxa Star Trek, Star Wars, Stargate...
    _investigationFuture = _searchSeriesCategory('CSI'); // Puxa CSI, NCIS...
    _fantasyFuture = _searchSeriesCategory(
        'Dragon'); // Puxa House of the Dragon, Dragon Ball...
  }

  Future<List<MediaContent>> _loadTrendingSeries() async {
    final raw = await ApiService.fetchTrendingSeries();
    return raw.map(_mapToMediaContent).toList();
  }

  Future<List<MediaContent>> _searchSeriesCategory(String query) async {
    final raw = await ApiService.searchSeries(query);
    return raw.map(_mapToMediaContent).toList();
  }

  MediaContent _mapToMediaContent(Map<String, dynamic> s) {
    return MediaContent(
      id: (s['imdb_id'] as String?) ?? s['tmdb_id'].toString(),
      title: (s['title'] as String?) ?? '',
      poster: (s['poster_url'] as String?) ?? '',
      backdrop: (s['backdrop_url'] as String?) ?? '',
      synopsis: (s['overview'] as String?) ?? '',
      publicDomain: false,
      externalLink: null,
      imdb: (s['vote_average'] as num?)?.toDouble() ?? 0.0,
      rottenTomatoes: null,
      genre: '',
      year: _parseYear(s['first_air_date'] as String?),
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

  void _reloadAll() {
    setState(() {
      _loadAllCatalogs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MediaContent>>(
      future: _trendingFuture, // O Future principal controla o Banner e a Home
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
                  'Não foi possível carregar as séries.\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _reloadAll,
                  child: const Text('Tentar novamente'),
                ),
              ],
            ),
          );
        }

        final series = snapshot.data ?? [];
        if (series.isEmpty) {
          return const Center(child: Text('Nenhuma série encontrada.'));
        }

        // Ordena para criar a prateleira de "Melhor Avaliadas"
        final topRated = [...series]..sort((a, b) => b.imdb.compareTo(a.imdb));
        final bannerItems =
            series.take(3).toList(); // Aumentei para 3 no Banner

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Hero Banner
              if (bannerItems.isNotEmpty)
                CarouselSlider(
                  options: CarouselOptions(
                    height: 380,
                    autoPlay: true,
                    autoPlayInterval: const Duration(seconds: 7),
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

              // 2. Prateleira: Em Destaque (Vem do trending)
              HorizontalShelf(
                title: 'Séries Clássicas em Destaque',
                items: series,
                onItemTap: (item) => _goToDetail(context, item),
              ),

              // 3. Prateleira: Melhor Avaliadas (Vem do trending ordenado)
              HorizontalShelf(
                title: 'Melhor Avaliadas pela Crítica',
                items: topRated,
                onItemTap: (item) => _goToDetail(context, item),
              ),

              // 4. Prateleira Temática: Sci-Fi (Carrega independente)
              _AsyncSeriesShelf(
                title: 'Sci-Fi & Exploração Espacial',
                future: _scifiFuture,
                onTap: (item) => _goToDetail(context, item),
              ),

              // 5. Prateleira Temática: Investigação (Carrega independente)
              _AsyncSeriesShelf(
                title: 'Investigação & Mistério',
                future: _investigationFuture,
                onTap: (item) => _goToDetail(context, item),
              ),

              // 6. Prateleira Temática: Fantasia (Carrega independente)
              _AsyncSeriesShelf(
                title: 'Épicos de Fantasia',
                future: _fantasyFuture,
                onTap: (item) => _goToDetail(context, item),
              ),

              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }
}

/// Widget customizado para carregar prateleiras de séries de forma assíncrona.
/// Se houver erro ou a lista vier vazia, ele simplesmente "encolhe" e não quebra a tela.
class _AsyncSeriesShelf extends StatelessWidget {
  final String title;
  final Future<List<MediaContent>> future;
  final Function(MediaContent) onTap;

  const _AsyncSeriesShelf({
    required this.title,
    required this.future,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MediaContent>>(
      future: future,
      builder: (context, snapshot) {
        // Enquanto carrega, mostra um espaço vazio ou nada para não piscar a tela
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }

        // Se der erro ou vier vazio, a prateleira some silenciosamente (graceful degradation)
        if (snapshot.hasError || (snapshot.data?.isEmpty ?? true)) {
          return const SizedBox.shrink();
        }

        // Se deu tudo certo, desenha a prateleira usando o seu HorizontalShelf original!
        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: HorizontalShelf(
            title: title,
            items: snapshot.data!,
            onItemTap: onTap,
          ),
        );
      },
    );
  }
}
