import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../services/api_service.dart';

class MinhaListaScreen extends StatefulWidget {
  const MinhaListaScreen({super.key});

  @override
  State<MinhaListaScreen> createState() => _MinhaListaScreenState();
}

class _MinhaListaScreenState extends State<MinhaListaScreen> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = ApiService.fetchFavorites();
  }

  void _refresh() {
    setState(() {
      _future = ApiService.fetchFavorites();
    });
  }

  Future<void> _removeItem(String movieId) async {
    try {
      await ApiService.removeFavorite(movieId);
      _refresh();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Removido da sua lista'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao remover: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minha Lista'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.white),
            tooltip: 'Atualizar',
            onPressed: _refresh,
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryAccent),
            );
          }

          if (snapshot.hasError) {
            return _ErrorState(
              message: snapshot.error.toString(),
              onRetry: _refresh,
            );
          }

          final items = snapshot.data ?? [];

          if (items.isEmpty) {
            return const _EmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return _FavoriteCard(
                item: item,
                onRemove: () => _removeItem(item['movie_id']?.toString() ?? ''),
              );
            },
          );
        },
      ),
    );
  }
}

// ─── Card de item ────────────────────────────────────────────────────────────

class _FavoriteCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onRemove;

  const _FavoriteCard({required this.item, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final title = item['movie_title']?.toString() ?? 'Sem título';
    final posterUrl = item['poster_url']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.secondary.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          // Poster
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
            child: posterUrl.isNotEmpty
                ? Image.network(
                    posterUrl,
                    width: 80,
                    height: 110,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _posterPlaceholder(title),
                  )
                : _posterPlaceholder(title),
          ),

          // Título e ações
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  const Row(
                    children: [
                      Icon(Icons.bookmark, size: 14, color: AppColors.primaryAccent),
                      SizedBox(width: 4),
                      Text(
                        'Salvo na lista',
                        style: TextStyle(fontSize: 12, color: AppColors.softAccent),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Botão remover
          IconButton(
            icon: const Icon(Icons.bookmark_remove_outlined, color: AppColors.grey),
            tooltip: 'Remover da lista',
            onPressed: () => _confirmRemove(context),
          ),
        ],
      ),
    );
  }

  Widget _posterPlaceholder(String title) {
    return Container(
      width: 80,
      height: 110,
      color: AppColors.secondary,
      child: Center(
        child: Text(
          title.isNotEmpty ? title[0].toUpperCase() : '?',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.softAccent,
          ),
        ),
      ),
    );
  }

  void _confirmRemove(BuildContext context) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Remover da lista'),
        content: Text(
          'Deseja remover "${item['movie_title']}" da sua lista?',
          style: const TextStyle(color: AppColors.softAccent),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx, true);
              onRemove();
            },
            child: const Text('Remover', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}

// ─── Estado vazio ────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.secondary),
            ),
            child: const Icon(Icons.bookmark_border,
                size: 48, color: AppColors.softAccent),
          ),
          const SizedBox(height: 24),
          const Text(
            'Sua lista está vazia',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Adicione filmes, séries e livros usando o ícone de favorito nas telas de detalhes.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: AppColors.grey, fontSize: 14, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Estado de erro ──────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, size: 56, color: AppColors.softAccent),
            const SizedBox(height: 16),
            const Text(
              'Não foi possível carregar',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.grey, fontSize: 13),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}
