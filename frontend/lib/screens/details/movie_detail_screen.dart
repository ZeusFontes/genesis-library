import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/colors.dart';
import '../../models/media_content.dart';
import '../../widgets/public_domain_player.dart';
import '../../widgets/streaming_button.dart';

class MovieDetailScreen extends StatelessWidget {
  const MovieDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final content = ModalRoute.of(context)!.settings.arguments as MediaContent;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Backdrop com botão voltar
            SizedBox(
              height: 280,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: content.backdrop,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => Container(color: AppColors.surface),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [AppColors.background, Colors.transparent],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 40,
                    left: 16,
                    child: SafeArea(
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.white),
                        onPressed: () => Navigator.pop(context),
                        style: IconButton.styleFrom(backgroundColor: AppColors.surface.withOpacity(0.8)),
                      ),
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
                  // Poster + Info
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CachedNetworkImage(
                          imageUrl: content.poster,
                          width: 90,
                          height: 130,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => Container(
                            width: 90, height: 130,
                            color: AppColors.secondary,
                            child: const Icon(Icons.movie, color: AppColors.white),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(content.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                _Badge('⭐ ${content.imdb} IMDB', AppColors.softAccent),
                                _Badge('🍅 ${content.rottenTomatoes.toInt()}%', Colors.redAccent),
                                _Badge(content.genre, AppColors.grey),
                                if (content.year != null) _Badge('${content.year}', AppColors.grey),
                                _Badge(
                                  content.publicDomain ? 'Domínio Público' : 'Streaming',
                                  content.publicDomain ? AppColors.primaryAccent : AppColors.secondary,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Sinopse
                  const Text('Sinopse', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(content.synopsis, style: const TextStyle(color: AppColors.grey, fontSize: 14, height: 1.6)),

                  const SizedBox(height: 24),

                  // Player ou Streaming — REGRA DE NEGÓCIO PRINCIPAL
                  if (content.publicDomain)
                    PublicDomainPlayer(videoUrl: 'mock_video.mp4')
                  else
                    StreamingButton(
                      serviceName: content.externalLink!.contains('netflix') ? 'Netflix' : 'Streaming',
                      url: content.externalLink!,
                    ),

                  // Elenco (se houver)
                  if (content.cast.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Text('Elenco', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: content.cast.map((name) => Chip(label: Text(name))).toList(),
                    ),
                  ],

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;

  const _Badge(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        border: Border.all(color: color.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 12)),
    );
  }
}
