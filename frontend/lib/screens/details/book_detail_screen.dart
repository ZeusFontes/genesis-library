// frontend/lib/screens/details/book_detail_screen.dart
//
// L2: "Baixar PDF" faz download dentro do app via DownloadsManager; registra em Downloads.
// CORREÇÃO: "Ler Agora" e "Ver no Google Books" usam LinkHelper para abrir em nova aba e evitar tela branca.
// FAV1: Botão de favoritar no AppBar com estado StatefulWidget.

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/colors.dart';
import '../../services/api_service.dart';
import '../../services/downloads_manager.dart';
import '../home/home_books_screen.dart';
import '../../utils/link_helper.dart'; // Ajudante de links externos

class BookDetailScreen extends StatefulWidget {
  const BookDetailScreen({super.key});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  bool _loadingReadUrl = false;
  String? _readUrl;

  // FAV1
  bool _isFavorited = false;
  bool _loadingFav = true;

  // L2
  bool _downloading = false;
  double _downloadProgress = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final book = ModalRoute.of(context)?.settings.arguments as BookItem?;
    if (book == null) return;

    if (book.publicDomain && _readUrl == null && !_loadingReadUrl) {
      _loadReadUrl(book.title);
    }
    _checkFavorite(book.id);
  }

  Future<void> _loadReadUrl(String title) async {
    setState(() => _loadingReadUrl = true);
    final url = await ApiService.fetchOpenLibraryReadUrl(title);
    if (mounted) {
      setState(() {
        _readUrl = url;
        _loadingReadUrl = false;
      });
    }
  }

  // FAV1
  Future<void> _checkFavorite(String bookId) async {
    setState(() => _loadingFav = true);
    try {
      final favs = await ApiService.fetchFavorites();
      final favId = 'book:$bookId';
      if (mounted) {
        setState(() {
          _isFavorited = favs.any((f) => f['movie_id'] == favId);
          _loadingFav = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingFav = false);
    }
  }

  Future<void> _toggleFavorite(BookItem book) async {
    final wasF = _isFavorited;
    setState(() => _isFavorited = !wasF);
    try {
      if (wasF) {
        await ApiService.removeFavorite('book:${book.id}');
      } else {
        await ApiService.addFavorite(
            movieId: 'book:${book.id}', movieTitle: book.title);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            wasF ? 'Removido dos favoritos.' : 'Adicionado aos favoritos!'),
      ));
    } catch (e) {
      if (mounted) setState(() => _isFavorited = wasF);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: ${e.toString()}')),
        );
      }
    }
  }

  // L2: Download do PDF dentro do app
  Future<void> _downloadPdf(BookItem book) async {
    // Prioriza link direto; senão busca via Gutenberg
    final pdfUrl = book.previewLink != null
        ? 'https://www.gutenberg.org/ebooks/search/?query=${Uri.encodeQueryComponent(book.title)}'
        : null;

    // Tenta buscar PDF real do Open Library ou Gutenberg
    final gutenbergUrl =
        'https://www.gutenberg.org/ebooks/search/?query=${Uri.encodeQueryComponent(book.title)}';
    final downloadUrl = pdfUrl ?? gutenbergUrl;

    setState(() {
      _downloading = true;
      _downloadProgress = 0;
    });
    try {
      final path = await DownloadsManager.instance.downloadPdf(
        id: book.id,
        title: book.title,
        url: downloadUrl,
        onProgress: (p) {
          if (mounted) setState(() => _downloadProgress = p);
        },
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('PDF baixado! Acesse em Downloads.'),
          action: SnackBarAction(
            label: 'Ver',
            onPressed: () => Navigator.pushNamed(context, '/downloads'),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha no download: $e')),
      );
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final book = ModalRoute.of(context)?.settings.arguments as BookItem?;

    if (book == null) {
      return Scaffold(
          appBar: AppBar(),
          body: const Center(child: Text('Livro não encontrado.')));
    }

    final coverUrl = ApiService.fixImageUrl(book.cover);

    return Scaffold(
      appBar: AppBar(
        title: Text(book.title, overflow: TextOverflow.ellipsis),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        // FAV1: botão de favoritar no AppBar
        actions: [
          if (_loadingFav)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(
                  child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))),
            )
          else
            IconButton(
              icon: Icon(
                _isFavorited ? Icons.bookmark : Icons.bookmark_border,
                color: _isFavorited ? AppColors.primaryAccent : AppColors.white,
              ),
              tooltip: _isFavorited
                  ? 'Remover dos favoritos'
                  : 'Adicionar aos favoritos',
              onPressed: () => _toggleFavorite(book),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: coverUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: coverUrl,
                          width: 120,
                          height: 175,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => _coverPlaceholder(),
                        )
                      : _coverPlaceholder(),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(book.title,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text(book.author,
                          style: const TextStyle(
                              color: AppColors.softAccent, fontSize: 14)),
                      const SizedBox(height: 10),
                      if (book.genre.isNotEmpty)
                        _Badge(book.genre, AppColors.secondary),
                      const SizedBox(height: 6),
                      _Badge(
                        book.publicDomain
                            ? '✓ Domínio Público'
                            : 'Google Books',
                        book.publicDomain
                            ? AppColors.primaryAccent
                            : AppColors.grey,
                      ),
                      if (book.publishedDate != null &&
                          book.publishedDate!.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        _Badge('📅 ${book.publishedDate!.substring(0, 4)}',
                            AppColors.grey),
                      ],
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            const Text('Sobre o Livro',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              book.synopsis.isNotEmpty
                  ? book.synopsis
                  : 'Descrição não disponível.',
              style: const TextStyle(
                  color: AppColors.grey, fontSize: 14, height: 1.7),
            ),

            const SizedBox(height: 28),

            // Ações
            if (book.publicDomain) ...[
              if (_loadingReadUrl)
                const Center(child: CircularProgressIndicator())
              else ...[
                // CORREÇÃO: "Ler Agora" abre em nova aba
                if (_readUrl != null)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          LinkHelper.openExternalLink(context, _readUrl),
                      icon: const Icon(Icons.menu_book),
                      label: const Text('Ler Agora — Grátis'),
                    ),
                  ),
                const SizedBox(height: 12),

                // L2: "Baixar PDF" — download dentro do app
                SizedBox(
                  width: double.infinity,
                  child: _downloading
                      ? Column(
                          children: [
                            LinearProgressIndicator(
                                value: _downloadProgress > 0
                                    ? _downloadProgress
                                    : null),
                            const SizedBox(height: 8),
                            Text(
                              _downloadProgress > 0
                                  ? 'Baixando... ${(_downloadProgress * 100).toStringAsFixed(0)}%'
                                  : 'Iniciando download...',
                              style: const TextStyle(
                                  color: AppColors.grey, fontSize: 12),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        )
                      : OutlinedButton.icon(
                          onPressed: DownloadsManager.instance
                                  .isDownloaded(book.id)
                              ? () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text(
                                          'Já baixado! Acesse em Downloads.'),
                                      action: SnackBarAction(
                                        label: 'Ver',
                                        onPressed: () => Navigator.pushNamed(
                                            context, '/downloads'),
                                      ),
                                    ),
                                  );
                                }
                              : () => _downloadPdf(book),
                          icon: Icon(
                            DownloadsManager.instance.isDownloaded(book.id)
                                ? Icons.download_done
                                : Icons.download,
                          ),
                          label: Text(
                            DownloadsManager.instance.isDownloaded(book.id)
                                ? 'PDF Baixado ✓'
                                : 'Baixar PDF',
                          ),
                        ),
                ),
              ],
            ] else if (book.previewLink != null && book.previewLink!.isNotEmpty)
              // CORREÇÃO: Google Books preview abre em nova aba
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primaryAccent),
                    foregroundColor: AppColors.primaryAccent,
                  ),
                  onPressed: () =>
                      LinkHelper.openExternalLink(context, book.previewLink),
                  icon: const Icon(Icons.book_outlined),
                  label: const Text('Ver no Google Books'),
                ),
              ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _coverPlaceholder() => Container(
        width: 120,
        height: 175,
        decoration: BoxDecoration(
          color: AppColors.secondary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.menu_book, color: AppColors.white, size: 48),
      );
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  const _Badge(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        border: Border.all(color: color.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 12)),
    );
  }
}
