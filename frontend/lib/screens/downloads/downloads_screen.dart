import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/colors.dart';
import '../../mocks/media_mock.dart';
import '../../models/media_content.dart';

class DownloadsScreen extends StatefulWidget {
  const DownloadsScreen({super.key});

  @override
  State<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends State<DownloadsScreen> {
  // Apenas filmes de domínio público aparecem como "baixados"
  late List<_DownloadItem> _downloads;

  @override
  void initState() {
    super.initState();
    final publicMovies = MediaMock.movies.where((m) => m.publicDomain).toList();
    _downloads = publicMovies.map((m) => _DownloadItem(content: m)).toList();
  }

  void _removeDownload(String id) {
    setState(() => _downloads.removeWhere((d) => d.content.id == id));
  }

  void _clearAll() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Remover todos os downloads?'),
        content: const Text(
          'Esta ação não pode ser desfeita.',
          style: TextStyle(color: AppColors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.softAccent)),
          ),
          TextButton(
            onPressed: () {
              setState(() => _downloads.clear());
              Navigator.pop(context);
            },
            child: const Text('Remover', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Downloads'),
        actions: [
          if (_downloads.isNotEmpty)
            TextButton(
              onPressed: _clearAll,
              child: const Text('Limpar tudo', style: TextStyle(color: Colors.redAccent, fontSize: 13)),
            ),
        ],
      ),
      body: _downloads.isEmpty ? _EmptyDownloads() : _DownloadList(
        downloads: _downloads,
        onRemove: _removeDownload,
      ),
    );
  }
}

class _DownloadItem {
  final MediaContent content;
  double progress;
  bool completed;

  _DownloadItem({
    required this.content,
    this.progress = 1.0,
    this.completed = true,
  });
}

class _EmptyDownloads extends StatelessWidget {
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
            child: const Icon(Icons.download_outlined, size: 48, color: AppColors.softAccent),
          ),
          const SizedBox(height: 24),
          const Text(
            'Nenhum download',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Conteúdos de domínio público\npodem ser baixados para assistir offline.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.grey, fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _DownloadList extends StatelessWidget {
  final List<_DownloadItem> downloads;
  final void Function(String) onRemove;

  const _DownloadList({required this.downloads, required this.onRemove});

  String _formatSize() {
    final mb = (downloads.length * 847.4);
    return mb >= 1000 ? '${(mb / 1024).toStringAsFixed(1)} GB' : '${mb.toStringAsFixed(0)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Resumo de armazenamento
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.secondary.withOpacity(0.4)),
          ),
          child: Row(
            children: [
              const Icon(Icons.storage_outlined, color: AppColors.primaryAccent, size: 28),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Armazenamento usado', style: TextStyle(fontSize: 12, color: AppColors.grey)),
                  Text(
                    _formatSize(),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                '${downloads.length} ${downloads.length == 1 ? 'item' : 'itens'}',
                style: const TextStyle(color: AppColors.softAccent, fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Disponível offline',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...downloads.map((d) => _DownloadTile(item: d, onRemove: () => onRemove(d.content.id))),
      ],
    );
  }
}

class _DownloadTile extends StatelessWidget {
  final _DownloadItem item;
  final VoidCallback onRemove;

  const _DownloadTile({required this.item, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.secondary.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: item.content.poster,
              width: 60,
              height: 85,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => Container(
                width: 60, height: 85,
                color: AppColors.secondary,
                child: const Icon(Icons.movie, color: AppColors.white, size: 28),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.content.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  item.content.genre,
                  style: const TextStyle(color: AppColors.grey, fontSize: 12),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.check_circle, color: AppColors.primaryAccent, size: 14),
                    const SizedBox(width: 4),
                    const Text(
                      'Disponível offline',
                      style: TextStyle(color: AppColors.primaryAccent, fontSize: 12),
                    ),
                    const SizedBox(width: 8),
                    const Text('•', style: TextStyle(color: AppColors.grey)),
                    const SizedBox(width: 8),
                    Text(
                      '${(847 + item.content.id.length * 13)} MB',
                      style: const TextStyle(color: AppColors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.grey),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}
