import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/constants/colors.dart';
import '../models/media_content.dart';

class HeroBanner extends StatelessWidget {
  final MediaContent content;
  final VoidCallback onWatch;
  final VoidCallback onDetails;

  const HeroBanner({
    super.key,
    required this.content,
    required this.onWatch,
    required this.onDetails,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 380,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: content.backdrop,
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(color: AppColors.surface),
            errorWidget: (_, __, ___) => Container(color: AppColors.surface),
          ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [AppColors.background, Colors.transparent],
                stops: [0.0, 0.7],
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 24,
            right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (content.publicDomain)
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryAccent.withOpacity(0.2),
                      border: Border.all(color: AppColors.primaryAccent.withOpacity(0.6)),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'DOMÍNIO PÚBLICO',
                      style: TextStyle(
                        color: AppColors.primaryAccent,
                        fontSize: 11,
                        letterSpacing: 2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                Text(
                  content.title,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(color: Colors.black54, blurRadius: 8)],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star, color: AppColors.softAccent, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${content.imdb} IMDB',
                      style: const TextStyle(color: AppColors.softAccent, fontSize: 13),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      content.genre,
                      style: const TextStyle(color: AppColors.grey, fontSize: 13),
                    ),
                    if (content.year != null) ...[
                      const SizedBox(width: 16),
                      Text(
                        '${content.year}',
                        style: const TextStyle(color: AppColors.grey, fontSize: 13),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: onWatch,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Assistir'),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: onDetails,
                      child: const Text('Mais detalhes'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
