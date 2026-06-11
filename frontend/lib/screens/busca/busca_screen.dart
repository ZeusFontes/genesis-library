import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/routes.dart';
import '../../models/media_content.dart';
import '../../screens/home/home_books_screen.dart';
import '../../services/api_service.dart';

class BuscaScreen extends StatefulWidget {
  const BuscaScreen({super.key});

  @override
  State<BuscaScreen> createState() => _BuscaScreenState();
}

class _BuscaScreenState extends State<BuscaScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  String _query = '';
  String _selectedFilter = 'Todos';
  bool _isLoading = false;
  String? _errorMessage;

  List<MediaContent> _movieResults = [];
  List<MediaContent> _seriesResults = [];
  List<BookItem> _bookResults = [];

  Timer? _debounce;

  final _filters = ['Todos', 'Filmes', 'Séries', 'Livros'];

  static const _recentSearches = ['Nosferatu', 'Breaking Bad', 'Dom Quixote', 'Fritz Lang'];

  static const _popularCategories = <(String, IconData, Color)>[
    ('Terror', Icons.nightlight_round, Colors.deepPurpleAccent),
    ('Drama', Icons.theater_comedy_outlined, Colors.blueAccent),
    ('Sci-Fi', Icons.rocket_launch_outlined, Colors.tealAccent),
    ('Clássicos', Icons.history_edu_outlined, Colors.amberAccent),
    ('Aventura', Icons.explore_outlined, Colors.greenAccent),
    ('Domínio Público', Icons.public_outlined, AppColors.primaryAccent),
  ];

  List<dynamic> get _results {
    final all = <dynamic>[];
    if (_selectedFilter == 'Todos' || _selectedFilter == 'Filmes') all.addAll(_movieResults);
    if (_selectedFilter == 'Todos' || _selectedFilter == 'Séries') all.addAll(_seriesResults);
    if (_selectedFilter == 'Todos' || _selectedFilter == 'Livros') all.addAll(_bookResults);
    return all;
  }

  void _onQueryChanged(String value) {
    setState(() { _query = value; _errorMessage = null; });
    _debounce?.cancel();
    if (value.trim().isEmpty) {
      setState(() {
        _movieResults = [];
        _seriesResults = [];
        _bookResults = [];
        _isLoading = false;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 600), () => _search(value));
  }

  Future<void> _search(String query) async {
    setState(() => _isLoading = true);
    try {
      final futures = await Future.wait([
        if (_selectedFilter == 'Todos' || _selectedFilter == 'Filmes')
          ApiService.searchMovies(query)
        else
          Future.value(<Map<String, dynamic>>[]),
        if (_selectedFilter == 'Todos' || _selectedFilter == 'Séries')
          ApiService.searchSeries(query)
        else
          Future.value(<Map<String, dynamic>>[]),
        if (_selectedFilter == 'Todos' || _selectedFilter == 'Livros')
          ApiService.searchBooks(query)
        else
          Future.value(<Map<String, dynamic>>[]),
      ]);

      if (!mounted) return;
      setState(() {
        _movieResults = futures[0].map(_mapMovie).toList();
        _seriesResults = futures[1].map(_mapSeries).toList();
        _bookResults = futures[2].map(_mapBook).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erro ao buscar: ${e.toString().replaceAll('ApiException', '').trim()}';
      });
    }
  }

  MediaContent _mapMovie(Map<String, dynamic> m) => MediaContent(
        id: (m['imdb_id'] as String?) ?? m['tmdb_id'].toString(),
        title: (m['title'] as String?) ?? '',
        poster: (m['poster_url'] as String?) ?? '',
        backdrop: (m['backdrop_url'] as String?) ?? '',
        synopsis: (m['overview'] as String?) ?? '',
        publicDomain: (m['public_domain'] as bool?) ?? false,
        externalLink: m['streaming_link'] as String?,
        streamingName: m['streaming_name'] as String?,
        imdb: (m['imdb_score'] as num?)?.toDouble() ??
            (m['vote_average'] as num?)?.toDouble() ?? 0.0,
        rottenTomatoes: m['rt_score'] as int?,
        genre: 'Filme',
        year: m['release_date'] != null && (m['release_date'] as String).length >= 4
            ? int.tryParse((m['release_date'] as String).substring(0, 4))
            : null,
        cast: const [],
      );

  MediaContent _mapSeries(Map<String, dynamic> s) => MediaContent(
        id: (s['imdb_id'] as String?) ?? s['tmdb_id'].toString(),
        title: (s['title'] as String?) ?? '',
        poster: (s['poster_url'] as String?) ?? '',
        backdrop: (s['backdrop_url'] as String?) ?? '',
        synopsis: (s['overview'] as String?) ?? '',
        publicDomain: false,
        imdb: (s['vote_average'] as num?)?.toDouble() ?? 0.0,
        rottenTomatoes: null,
        genre: 'Série',
        year: s['first_air_date'] != null && (s['first_air_date'] as String).length >= 4
            ? int.tryParse((s['first_air_date'] as String).substring(0, 4))
            : null,
        cast: const [],
      );

  BookItem _mapBook(Map<String, dynamic> m) {
    final authors = (m['authors'] as List<dynamic>?)?.join(', ') ?? 'Desconhecido';
    final cover = ApiService.fixImageUrl(m['thumbnail'] as String?);
    final publishedDate = m['published_date'] as String?;
    final title = (m['title'] as String?) ?? 'Sem título';
    final description = (m['description'] as String?) ?? '';
    final isPD = (m['public_domain'] as bool?) ??
        ApiService.isPublicDomain(publishedDate, title, description);
    return BookItem(
      id: (m['id'] as String?) ?? '',
      title: title,
      author: authors,
      cover: cover,
      synopsis: description,
      publicDomain: isPD,
      genre: 'Livro',
      previewLink: m['preview_link'] as String?,
      readUrl: m['read_url'] as String?,
      publishedDate: publishedDate,
    );
  }

  void _onTapResult(dynamic item) {
    if (item is MediaContent) {
      Navigator.pushNamed(context, AppRoutes.movieDetail, arguments: item);
    } else if (item is BookItem) {
      Navigator.pushNamed(context, AppRoutes.bookDetail, arguments: item);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusNode.requestFocus());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          controller: _controller,
          focusNode: _focusNode,
          autofocus: true,
          style: const TextStyle(color: AppColors.white),
          decoration: InputDecoration(
            hintText: 'Buscar filmes, séries, livros...',
            hintStyle: const TextStyle(color: AppColors.grey),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            fillColor: Colors.transparent,
            contentPadding: EdgeInsets.zero,
            suffixIcon: _query.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close, color: AppColors.grey, size: 20),
                    onPressed: () { _controller.clear(); _onQueryChanged(''); },
                  )
                : null,
          ),
          onChanged: _onQueryChanged,
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: _filters.map((f) {
                final selected = _selectedFilter == f;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedFilter = f);
                    if (_query.isNotEmpty) _search(_query);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primaryAccent : AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected ? AppColors.primaryAccent : AppColors.secondary,
                      ),
                    ),
                    child: Text(
                      f,
                      style: TextStyle(
                        color: selected ? Colors.black : AppColors.softAccent,
                        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          if (_isLoading) const LinearProgressIndicator(minHeight: 2),
          Expanded(
            child: _query.isEmpty
                ? _EmptyState(recentSearches: _recentSearches, popularCategories: _popularCategories)
                : _errorMessage != null
                    ? Center(child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, color: AppColors.grey, size: 48),
                            const SizedBox(height: 12),
                            Text(_errorMessage!, textAlign: TextAlign.center,
                                style: const TextStyle(color: AppColors.grey)),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => _search(_query),
                              child: const Text('Tentar novamente'),
                            ),
                          ],
                        ),
                      ))
                    : _ResultsView(results: _results, query: _query, onTap: _onTapResult),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final List<String> recentSearches;
  final List<(String, IconData, Color)> popularCategories;
  const _EmptyState({required this.recentSearches, required this.popularCategories});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Buscas recentes', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...recentSearches.map((s) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.history, color: AppColors.grey, size: 20),
              title: Text(s, style: const TextStyle(fontSize: 14)),
              trailing: const Icon(Icons.north_west, color: AppColors.grey, size: 16),
              onTap: () {},
              dense: true,
            )),
        const SizedBox(height: 24),
        const Text('Explorar por categoria', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 2.8,
          children: popularCategories.map((cat) {
            return Container(
              decoration: BoxDecoration(
                color: (cat.$3).withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: (cat.$3).withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(cat.$2, color: cat.$3, size: 18),
                  const SizedBox(width: 8),
                  Text(cat.$1, style: TextStyle(color: cat.$3, fontSize: 13, fontWeight: FontWeight.w600)),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _ResultsView extends StatelessWidget {
  final List<dynamic> results;
  final String query;
  final void Function(dynamic) onTap;
  const _ResultsView({required this.results, required this.query, required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 56, color: AppColors.softAccent),
            const SizedBox(height: 16),
            Text('Nenhum resultado para "$query"',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Tente outro termo ou categoria.', style: TextStyle(color: AppColors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      itemCount: results.length,
      itemBuilder: (_, i) {
        final item = results[i];
        if (item is MediaContent) return _MediaResultTile(item: item, onTap: () => onTap(item));
        if (item is BookItem) return _BookResultTile(item: item, onTap: () => onTap(item));
        return const SizedBox();
      },
    );
  }
}

class _MediaResultTile extends StatelessWidget {
  final MediaContent item;
  final VoidCallback onTap;
  const _MediaResultTile({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: item.poster.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: item.poster, width: 54, height: 78, fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => _moviePlaceholder())
                  : _moviePlaceholder(),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 4),
                  Row(children: [
                    Text(item.genre, style: const TextStyle(color: AppColors.grey, fontSize: 12)),
                    if (item.year != null) ...[
                      const Text(' • ', style: TextStyle(color: AppColors.grey)),
                      Text('${item.year}', style: const TextStyle(color: AppColors.grey, fontSize: 12)),
                    ],
                    if (item.rottenTomatoes != null) ...[
                      const Text(' • ', style: TextStyle(color: AppColors.grey)),
                      Text('🍅 ${item.rottenTomatoes}%',
                          style: const TextStyle(color: AppColors.grey, fontSize: 12)),
                    ],
                  ]),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: item.publicDomain
                          ? AppColors.primaryAccent.withOpacity(0.15)
                          : AppColors.secondary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      item.publicDomain ? 'Domínio Público' : item.genre,
                      style: TextStyle(
                          fontSize: 10,
                          color: item.publicDomain ? AppColors.primaryAccent : AppColors.softAccent),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.grey, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _moviePlaceholder() => Container(
      width: 54, height: 78, color: AppColors.secondary,
      child: const Icon(Icons.movie, color: AppColors.white));
}

class _BookResultTile extends StatelessWidget {
  final BookItem item;
  final VoidCallback onTap;
  const _BookResultTile({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: item.cover.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: item.cover, width: 54, height: 78, fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => _bookPlaceholder())
                  : _bookPlaceholder(),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(item.author, style: const TextStyle(color: AppColors.grey, fontSize: 12)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: item.publicDomain
                          ? AppColors.primaryAccent.withOpacity(0.15)
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                          color: item.publicDomain
                              ? AppColors.primaryAccent.withOpacity(0.5)
                              : AppColors.secondary),
                    ),
                    child: Text(
                      item.publicDomain ? '📖 Grátis' : 'Livro',
                      style: TextStyle(
                          fontSize: 10,
                          color: item.publicDomain ? AppColors.primaryAccent : AppColors.softAccent),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.grey, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _bookPlaceholder() => Container(
      width: 54, height: 78, color: AppColors.secondary,
      child: const Icon(Icons.menu_book, color: AppColors.white));
}
