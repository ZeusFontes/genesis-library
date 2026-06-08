import 'package:flutter/material.dart';
import '../core/constants/colors.dart';

class PublicDomainPlayer extends StatelessWidget {
  final String videoUrl;

  const PublicDomainPlayer({super.key, required this.videoUrl});

  @override
  Widget build(BuildContext context) {
    // TODO: Integrar com video_player quando houver URL real
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.secondary),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Icon(Icons.movie_filter, size: 80, color: AppColors.secondary),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [AppColors.primaryAccent, AppColors.softAccent],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryAccent.withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.play_arrow, color: Colors.black, size: 36),
              onPressed: () {
                // TODO: Iniciar video_player com videoUrl
              },
            ),
          ),
          Positioned(
            bottom: 12,
            child: Text(
              'Conteúdo de Domínio Público',
              style: TextStyle(
                color: AppColors.grey.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
