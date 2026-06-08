import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/routes.dart';
import '../../mocks/media_mock.dart';
import '../../models/media_content.dart';
import '../../screens/home/home_books_screen.dart';

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

  final _filters = ['Todos', 'Filmes', 'Séries', 'Livros'];

  static const _recentSearches = ['Nosferatu', 'Breaking Bad', 'Dom Quixote', 'Fritz Lang'];
  static const _popularCategories = [
    ('Terror', Icons.nightlight_round, Colors.deepPurpleAccent),
    ('Drama', Icons.theater_comedy_outlined, Colors.blueAccent),
    ('Sci-Fi', Icons.rocket_launch_outlined, Colors.tealAccent),
    ('Clássicos', Icons.history_edu_outlined, Colors.amberAccent),
    ('Aventura', Icons.explore_outlined, Colors.greenAccent),
    ('Domínio Público', Icons.public_outlined, AppColors.primaryAccent),
  ];

  List<dynamic> get _results {
    if (_query.trim().isEmpty) return [];

    final q = _query.toLowerCase();
    final all = <dynamic>[];

    if (_selectedFilter == 'Todos' || _selectedFilter == 'Filmes') {
      all.addAll(MediaMock.movies.where((m) =>
          m.title.toLowerCase().contains(q) ||
          m.genre.toLowerCase().contains(q) ||
          m.synopsis.toLowerCase().contains(q)));
    }
    if (_selectedFilter == 'Todos' || _selectedFilter == 'Séries') {
      all.addAll(MediaMock.series.where((s) =>
          s.title.toLowerCase().contains(q) ||
          s.genre.toLowerCase().contains(q)));
    }
    if (_selectedFilter == 'Todos' || _selectedFilter == 'Livros') {
      all.addAll(mockBooks.where((b) =>
          b.title.toLowerCase().contains(q) ||
          b.author.toLowerCase().contains(q) ||
          b.genre.toLowerCase().contains(q)));
    }
    return all;
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
    // Auto-focus ao abrir a tela
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
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
                    onPressed: () {
                      _controller.clear();
                      setState(() => _query = '');
                    },
                  )
                : null,
          ),
          onChanged: (v) => setState(() => _query = v),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filtros
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: _filters.map((f) {
                final selected = _selectedFilter == f;
                return GestureDetector(
                  onTap: () => setState(() => _selectedFilter = f),
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

          Expanded(
            child: _query.isEmpty ? _EmptyState() : _ResultsView(
              results: _results,
              query: _query,
              onTap: _onTapResult,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Buscas recentes
        const Text('Buscas recentes', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...(_BuscaScreen._recentSearches.map((s) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.history, color: AppColors.grey, size: 20),
              title: Text(s, style: const TextStyle(fontSize: 14)),
              trailing: const Icon(Icons.north_west, color: AppColors.grey, size: 16),
              onTap: () {},
              dense: true,
            ))),

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
          children: _BuscaScreen._popularCategories.map((cat) {
            return Container(
              decoration: BoxDecoration(
                color: (cat.$3 as Color).withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: (cat.$3 as Color).withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(cat.$2 as IconData, color: cat.$3 as Color, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    cat.$1 as String,
                    style: TextStyle(
                      color: cat.$3 as Color,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// Necessário para acessar as constantes estáticas
extension on _BuscaScreenState {
  static const recentSearches = _BuscaScreen._recentSearches;
  static const popularCategories = _BuscaScreen._popularCategories;
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
            Text(
              'Nenhum resultado para "$query"',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tente outro termo ou categoria.',
              style: TextStyle(color: AppColors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      itemCount: results.length,
      itemBuilder: (_, i) {
        final item = results[i];
        if (item is MediaContent) {
          return _MediaResultTile(item: item, onTap: () => onTap(item));
        } else if (item is BookItem) {
          return _BookResultTile(item: item, onTap: () => onTap(item));
        }
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
              child: CachedNetworkImage(
                imageUrl: item.poster,
                width: 54,
                height: 78,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Container(
                  width: 54, height: 78,
                  color: AppColors.secondary,
                  child: const Icon(Icons.movie, color: AppColors.white),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(item.genre, style: const TextStyle(color: AppColors.grey, fontSize: 12)),
                      if (item.year != null) ...[
                        const Text(' • ', style: TextStyle(color: AppColors.grey)),
                        Text('${item.year}', style: const TextStyle(color: AppColors.grey, fontSize: 12)),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: (item.publicDomain ? AppColors.primaryAccent : AppColors.secondary).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      item.publicDomain ? 'Domínio Público' : 'Streaming',
                      style: TextStyle(
                        fontSize: 10,
                        color: item.publicDomain ? AppColors.primaryAccent : AppColors.softAccent,
                      ),
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
              child: CachedNetworkImage(
                imageUrl: item.cover,
                width: 54,
                height: 78,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Container(
                  width: 54, height: 78,
                  color: AppColors.secondary,
                  child: const Icon(Icons.menu_book, color: AppColors.white),
                ),
              ),
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
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.secondary),
                        ),
                        child: const Text('Livro', style: TextStyle(fontSize: 10, color: AppColors.softAccent)),
                      ),
                      const SizedBox(width: 6),
                      if (item.publicDomain)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryAccent.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('Grátis', style: TextStyle(fontSize: 10, color: AppColors.primaryAccent)),
                        ),
                    ],
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
}

// Hack para acessar estáticos internos na widget _EmptyState
class _BuscaScreen {
  static const _recentSearches = ['Nosferatu', 'Breaking Bad', 'Dom Quixote', 'Fritz Lang'];
  static const _popularCategories = <(String, IconData, Color)>[
    ('Terror', Icons.nightlight_round, Colors.deepPurpleAccent),
    ('Drama', Icons.theater_comedy_outlined, Colors.blueAccent),
    ('Sci-Fi', Icons.rocket_launch_outlined, Colors.tealAccent),
    ('Clássicos', Icons.history_edu_outlined, Colors.amberAccent),
    ('Aventura', Icons.explore_outlined, Colors.greenAccent),
    ('Domínio Público', Icons.public_outlined, AppColors.primaryAccent),
  ];
}
