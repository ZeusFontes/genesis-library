import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/routes.dart';
import '../../services/api_service.dart';

class BookItem {
  final String id;
  final String title;
  final String author;
  final String cover;
  final String synopsis;
  final bool publicDomain;
  final String genre;
  final String? previewLink;
  final String? readUrl;
  final String? publishedDate;

  BookItem({
    required this.id,
    required this.title,
    required this.author,
    required this.cover,
    required this.synopsis,
    required this.publicDomain,
    required this.genre,
    this.previewLink,
    this.readUrl,
    this.publishedDate,
  });
}

BookItem _mapToBookItem(Map<String, dynamic> m) {
  final authors =
      (m['authors'] as List<dynamic>?)?.join(', ') ?? 'Desconhecido';
  final rawCover = (m['thumbnail'] as String?) ?? '';
  final cover = ApiService.fixImageUrl(rawCover);
  final publishedDate = m['published_date'] as String?;
  final title = m['title'] as String? ?? '';
  final description = m['description'] as String? ?? '';
  final isPD = (m['public_domain'] as bool?) ??
      ApiService.isPublicDomain(publishedDate, title, description);

  return BookItem(
    id: m['id'] ?? '',
    title: title.isNotEmpty ? title : 'Sem título',
    author: authors,
    cover: cover,
    synopsis: description,
    publicDomain: isPD,
    genre: '',
    previewLink: m['preview_link'] as String?,
    readUrl: m['read_url'] as String?,
    publishedDate: publishedDate,
  );
}

class HomeBooksScreen extends StatefulWidget {
  const HomeBooksScreen({super.key});

  @override
  State<HomeBooksScreen> createState() => _HomeBooksScreenState();
}

class _HomeBooksScreenState extends State<HomeBooksScreen> {
  late Future<List<BookItem>> _publicDomainFuture;
  late Future<List<BookItem>> _libraryFuture;

  // Novas categorias para deixar o catálogo mais robusto
  late Future<List<BookItem>> _sciFiFuture;
  late Future<List<BookItem>> _romanceFuture;
  late Future<List<BookItem>> _businessFuture;

  @override
  void initState() {
    super.initState();
    _loadAllCatalogs();
  }

  void _loadAllCatalogs() {
    _publicDomainFuture = _fetchPublicDomain();
    _libraryFuture = _fetchLibrary();

    // Puxando as novas prateleiras usando a rota de busca do backend
    _sciFiFuture = _fetchCategory('ficção científica fantasia');
    _romanceFuture = _fetchCategory('romance literatura');
    _businessFuture = _fetchCategory('desenvolvimento negócios');
  }

  Future<List<BookItem>> _fetchPublicDomain() async {
    final raw = await ApiService.fetchPublicDomainBooks(
        q: 'clássicos literatura portuguesa poesia');
    return raw.map(_mapToBookItem).toList();
  }

  Future<List<BookItem>> _fetchLibrary() async {
    final raw = await ApiService.fetchLibraryBooks();
    return raw.map(_mapToBookItem).toList();
  }

  Future<List<BookItem>> _fetchCategory(String query) async {
    final raw = await ApiService.searchBooks(query, maxResults: 15);
    return raw.map(_mapToBookItem).toList();
  }

  void _reload() {
    setState(() {
      _loadAllCatalogs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 24, 20, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Biblioteca GÊNESIS',
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text('Explore milhares de mundos sem sair do lugar',
                    style: TextStyle(color: AppColors.grey, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _AsyncBookShelf(
            title: 'Domínio Público — Leitura Gratuita',
            future: _publicDomainFuture,
            onRetry: _reload,
          ),
          _AsyncBookShelf(
            title: 'Ficção Científica & Fantasia',
            future: _sciFiFuture,
            onRetry: _reload,
          ),
          _AsyncBookShelf(
            title: 'Romances Inesquecíveis',
            future: _romanceFuture,
            onRetry: _reload,
          ),
          _AsyncBookShelf(
            title: 'Desenvolvimento & Negócios',
            future: _businessFuture,
            onRetry: _reload,
          ),
          _AsyncBookShelf(
            title: 'Descubra Mais (Toda a Biblioteca)',
            future: _libraryFuture,
            onRetry: _reload,
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _AsyncBookShelf extends StatelessWidget {
  final String title;
  final Future<List<BookItem>> future;
  final VoidCallback onRetry;

  const _AsyncBookShelf(
      {required this.title, required this.future, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<BookItem>>(
      future: future,
      builder: (context, snapshot) {
        Widget content;
        if (snapshot.connectionState == ConnectionState.waiting) {
          content = const SizedBox(
              height: 260, child: Center(child: CircularProgressIndicator()));
        } else if (snapshot.hasError) {
          final errorMsg = snapshot.error is ApiException
              ? (snapshot.error as ApiException).message
              : snapshot.error.toString();
          content = SizedBox(
            height: 140,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        color: AppColors.grey, size: 32),
                    const SizedBox(height: 8),
                    Text(
                      'Não foi possível carregar livros:\n$errorMsg',
                      textAlign: TextAlign.center,
                      style:
                          const TextStyle(color: AppColors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            ),
          );
        } else if (snapshot.data?.isEmpty ?? true) {
          // Se uma categoria falhar silenciosamente, a prateleira encolhe e some pra não deixar buraco
          return const SizedBox.shrink();
        } else {
          content = SizedBox(
            height: 260,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: snapshot.data!.length,
              itemBuilder: (_, i) => _BookCard(book: snapshot.data![i]),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Text(title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            content,
          ],
        );
      },
    );
  }
}

class _BookCard extends StatelessWidget {
  final BookItem book;
  const _BookCard({required this.book});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          Navigator.pushNamed(context, AppRoutes.bookDetail, arguments: book),
      child: Container(
        width: 130,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.secondary.withOpacity(0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
              child: book.cover.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: book.cover,
                      height: 175,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => _placeholder(book.title),
                    )
                  : _placeholder(book.title),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(book.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 3),
                  Text(book.author,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: AppColors.softAccent, fontSize: 11)),
                  const SizedBox(height: 5),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: book.publicDomain
                          ? AppColors.primaryAccent.withOpacity(0.15)
                          : AppColors.secondary.withOpacity(0.3),
                      border: Border.all(
                          color: book.publicDomain
                              ? AppColors.primaryAccent.withOpacity(0.5)
                              : AppColors.secondary.withOpacity(0.5)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      book.publicDomain ? '📖 Grátis' : 'Ver detalhes',
                      style: TextStyle(
                          fontSize: 9,
                          color: book.publicDomain
                              ? AppColors.primaryAccent
                              : AppColors.grey),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Placeholder atualizado: Mostra o título do livro centralizado para disfarçar a falta da imagem
  Widget _placeholder(String title) => Container(
        height: 175,
        width: double.infinity,
        color: AppColors.secondary,
        padding: const EdgeInsets.all(8),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.menu_book, color: Colors.white54, size: 24),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      );
}
