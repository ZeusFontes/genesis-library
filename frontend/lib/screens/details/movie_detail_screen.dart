// frontend/lib/screens/details/movie_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/colors.dart';
import '../../models/media_content.dart';
import '../../services/api_service.dart';
import '../../widgets/in_app_webview_screen.dart';
import '../../utils/link_helper.dart';

class MovieDetailScreen extends StatefulWidget {
  const MovieDetailScreen({super.key});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  bool _isFavorited = false;
  bool _loadingFav = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final content = ModalRoute.of(context)?.settings.arguments as MediaContent?;
    if (content != null) _checkFavorite(content.id);
  }

  Future<void> _checkFavorite(String movieId) async {
    setState(() => _loadingFav = true);
    try {
      final favs = await ApiService.fetchFavorites();
      if (mounted) {
        setState(() {
          _isFavorited = favs.any((f) => f['movie_id'] == movieId);
          _loadingFav = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingFav = false);
    }
  }

  Future<void> _toggleFavorite(MediaContent content) async {
    final wasF = _isFavorited;
    setState(() => _isFavorited = !wasF);
    try {
      if (wasF) {
        await ApiService.removeFavorite(content.id);
      } else {
        await ApiService.addFavorite(movieId: content.id, movieTitle: content.title);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(wasF ? 'Removido dos favoritos.' : 'Adicionado aos favoritos!'),
      ));
    } catch (e) {
      if (mounted) setState(() => _isFavorited = wasF);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = ModalRoute.of(context)?.settings.arguments as MediaContent?;

    if (content == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Conteúdo não encontrado.')),
      );
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 280,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  content.backdrop.isNotEmpty
                      ? CachedNetworkImage(imageUrl: content.backdrop, fit: BoxFit.cover, errorWidget: (_, __, ___) => Container(color: AppColors.surface))
                      : Container(color: AppColors.surface),
                  Container(decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [AppColors.background, Colors.transparent]))),
                  Positioned(top: 40, left: 16, child: SafeArea(child: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.white), onPressed: () => Navigator.pop(context), style: IconButton.styleFrom(backgroundColor: AppColors.surface.withOpacity(0.8))))),
                  Positioned(
                    top: 40, right: 16,
                    child: SafeArea(
                      child: _loadingFav ? const SizedBox(width: 40, height: 40, child: Center(child: CircularProgressIndicator(strokeWidth: 2))) 
                      : IconButton(icon: Icon(_isFavorited ? Icons.favorite : Icons.favorite_border, color: _isFavorited ? Colors.red : AppColors.white, size: 28), style: IconButton.styleFrom(backgroundColor: AppColors.surface.withOpacity(0.8)), onPressed: () => _toggleFavorite(content)),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderInfo(content),
                  const SizedBox(height: 20),
                  const Text('Sinopse', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(content.synopsis.isNotEmpty ? content.synopsis : 'Sinopse não disponível.', style: const TextStyle(color: AppColors.grey, fontSize: 14, height: 1.6)),
                  const SizedBox(height: 24),
                  _buildStreamingButtons(content),
                  if (content.cast.isNotEmpty) _buildCastList(content),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderInfo(MediaContent content) => Row(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      if (content.poster.isNotEmpty) ClipRRect(borderRadius: BorderRadius.circular(10), child: CachedNetworkImage(imageUrl: content.poster, width: 90, height: 130, fit: BoxFit.cover, errorWidget: (_, __, ___) => _posterPlaceholder())) else _posterPlaceholder(),
      const SizedBox(width: 16),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(content.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8, runSpacing: 6,
              children: [
                if (content.imdb > 0) _Badge('⭐ ${content.imdb.toStringAsFixed(1)} IMDB', AppColors.softAccent),
                if (content.rottenTomatoes != null) _Badge('🍅 ${content.rottenTomatoes}% RT', const Color(0xFFFA320A)),
                if (content.genre.isNotEmpty) _Badge(content.genre, AppColors.grey),
                _Badge(content.publicDomain ? 'Domínio Público' : 'Streaming', content.publicDomain ? AppColors.primaryAccent : AppColors.secondary),
                if (content.streamingName != null && !content.publicDomain) _Badge('📺 ${content.streamingName}', AppColors.secondary),
              ],
            ),
          ],
        ),
      ),
    ],
  );

  Widget _buildStreamingButtons(MediaContent content) {
    // 1. Domínio Público
    if (content.publicDomain && (content.externalLink?.isNotEmpty ?? false)) {
      return ElevatedButton.icon(
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryAccent, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 14)),
        onPressed: () {
          String embedUrl = content.externalLink!.replaceFirst('/details/', '/embed/');
          if (kIsWeb) {
            LinkHelper.openExternalLink(context, content.externalLink);
          } else {
            InAppWebViewScreen.open(context, url: embedUrl, title: content.title);
          }
        },
        icon: const Icon(Icons.play_circle_fill),
        label: const Text('Assistir Gratuitamente', style: TextStyle(fontWeight: FontWeight.bold)),
      );
    } 
    // 2. Streaming Pago
    else if (content.externalLink != null && content.externalLink!.isNotEmpty) {
      return ElevatedButton.icon(
        onPressed: () => LinkHelper.openExternalLink(context, content.externalLink),
        icon: const Icon(Icons.play_arrow),
        label: Text(content.streamingName != null ? 'Assistir no ${content.streamingName}' : 'Assistir no Streaming'),
      );
    } 
    // 3. Rota de Fuga (Pesquisa Google)
    else {
      return OutlinedButton.icon(
        onPressed: () => LinkHelper.openExternalLink(context, "https://www.google.com/search?q=${Uri.encodeComponent(content.title)}+onde+assistir"),
        icon: const Icon(Icons.search),
        label: const Text('Pesquisar onde assistir no Google'),
      );
    }
  }

  Widget _buildCastList(MediaContent content) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 24),
      const Text('Elenco', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),
      Wrap(spacing: 8, runSpacing: 8, children: content.cast.map((name) => Chip(label: Text(name))).toList()),
    ],
  );

  Widget _posterPlaceholder() => Container(width: 90, height: 130, decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.movie, color: AppColors.white));
}

class _Badge extends StatelessWidget {
  final String text; final Color color;
  const _Badge(this.text, this.color);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: color.withOpacity(0.15), border: Border.all(color: color.withOpacity(0.5)), borderRadius: BorderRadius.circular(6)),
    child: Text(text, style: TextStyle(color: color, fontSize: 12)),
  );
}