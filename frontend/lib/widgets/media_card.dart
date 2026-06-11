import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../core/constants/colors.dart';
import '../models/media_content.dart';

class MediaCard extends StatelessWidget {
  final MediaContent item;
  final VoidCallback onTap;

  const MediaCard({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
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
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              child: item.poster.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: item.poster,
                      height: 195,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Shimmer.fromColors(
                        baseColor: AppColors.surface,
                        highlightColor: AppColors.secondary,
                        child: Container(height: 195, color: AppColors.surface),
                      ),
                      errorWidget: (_, __, ___) => _placeholder(),
                    )
                  : _placeholder(),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 7, 8, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(Icons.star, color: AppColors.softAccent, size: 11),
                      const SizedBox(width: 2),
                      Flexible(
                        child: Text(
                          item.imdb > 0 ? item.imdb.toStringAsFixed(1) : '—',
                          style: const TextStyle(color: AppColors.softAccent, fontSize: 10),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (item.rottenTomatoes != null) ...[
                        const SizedBox(width: 6),
                        const Text('🍅', style: TextStyle(fontSize: 9)),
                        const SizedBox(width: 2),
                        Flexible(
                          child: Text(
                            '${item.rottenTomatoes}%',
                            style: const TextStyle(color: AppColors.softAccent, fontSize: 10),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: item.publicDomain
                          ? AppColors.primaryAccent.withOpacity(0.15)
                          : AppColors.secondary.withOpacity(0.3),
                      border: Border.all(
                        color: item.publicDomain
                            ? AppColors.primaryAccent.withOpacity(0.5)
                            : AppColors.secondary.withOpacity(0.5),
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      item.publicDomain ? '🎬 Grátis' : 'Streaming',
                      style: TextStyle(
                        fontSize: 9,
                        color: item.publicDomain ? AppColors.primaryAccent : AppColors.grey,
                      ),
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

  Widget _placeholder() => Container(
        height: 195,
        color: AppColors.surface,
        child: const Center(child: Icon(Icons.broken_image, color: AppColors.grey)),
      );
}
