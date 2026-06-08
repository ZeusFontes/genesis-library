import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/routes.dart';
import '../../mocks/media_mock.dart';
import '../../models/media_content.dart';

class _HistoryEntry {
  final MediaContent content;
  final String timeLabel;
  final double watchedPercent;

  const _HistoryEntry({
    required this.content,
    required this.timeLabel,
    required this.watchedPercent,
  });
}

class HistoricoScreen extends StatefulWidget {
  const HistoricoScreen({super.key});

  @override
  State<HistoricoScreen> createState() => _HistoricoScreenState();
}

class _HistoricoScreenState extends State<HistoricoScreen> {
  late List<_HistoryEntry> _history;

  @override
  void initState() {
    super.initState();
    final all = [...MediaMock.movies, ...MediaMock.series];
    final labels = ['Agora mesmo', 'Há 2 horas', 'Ontem', 'Há 2 dias', 'Há 5 dias'];
    final percents = [0.43, 1.0, 0.18, 1.0, 0.72];
    _history = List.generate(
      all.length > 5 ? 5 : all.length,
      (i) => _HistoryEntry(
        content: all[i],
        timeLabel: labels[i % labels.length],
        watchedPercent: percents[i % percents.length],
      ),
    );
  }

  void _removeEntry(String id) {
    setState(() => _history.removeWhere((e) => e.content.id == id));
  }

  void _clearHistory() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Limpar histórico?'),
        content: const Text(
          'Isso removerá todo o seu histórico de visualização.',
          style: TextStyle(color: AppColors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.softAccent)),
          ),
          TextButton(
            onPressed: () {
              setState(() => _history.clear());
              Navigator.pop(context);
            },
            child: const Text('Limpar', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico'),
        actions: [
          if (_history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined, color: AppColors.softAccent),
              tooltip: 'Limpar histórico',
              onPressed: _clearHistory,
            ),
        ],
      ),
      body: _history.isEmpty
          ? _EmptyHistory()
          : ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'Continue de onde parou',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                ..._history.map((entry) => _HistoryTile(
                      entry: entry,
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRoutes.movieDetail,
                        arguments: entry.content,
                      ),
                      onRemove: () => _removeEntry(entry.content.id),
                    )),
              ],
            ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
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
            child: const Icon(Icons.history, size: 48, color: AppColors.softAccent),
          ),
          const SizedBox(height: 24),
          const Text(
            'Histórico vazio',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'O que você assistir aparecerá aqui\npara você continuar depois.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.grey, fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final _HistoryEntry entry;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _HistoryTile({
    required this.entry,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            // Thumbnail com barra de progresso
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: entry.content.backdrop,
                    width: 120,
                    height: 68,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => Container(
                      width: 120, height: 68,
                      color: AppColors.secondary,
                      child: const Icon(Icons.movie, color: AppColors.white),
                    ),
                  ),
                ),
                // Barra de progresso
                Positioned(
                  bottom: 0, left: 0, right: 0,
                  child: Container(
                    height: 3,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
                      color: AppColors.secondary,
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: entry.watchedPercent,
                      child: Container(
                        decoration: BoxDecoration(
                          color: entry.watchedPercent >= 1.0
                              ? AppColors.primaryAccent
                              : Colors.redAccent,
                          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
                        ),
                      ),
                    ),
                  ),
                ),
                // Ícone play
                Positioned.fill(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.background.withOpacity(0.6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.play_arrow, size: 20, color: AppColors.white),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.content.title,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    entry.timeLabel,
                    style: const TextStyle(color: AppColors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    entry.watchedPercent >= 1.0
                        ? 'Assistido completo'
                        : '${(entry.watchedPercent * 100).toInt()}% assistido',
                    style: TextStyle(
                      fontSize: 11,
                      color: entry.watchedPercent >= 1.0
                          ? AppColors.primaryAccent
                          : AppColors.softAccent,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 18, color: AppColors.grey),
              onPressed: onRemove,
            ),
          ],
        ),
      ),
    );
  }
}
