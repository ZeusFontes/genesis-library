import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../core/constants/routes.dart';
import '../../mocks/media_mock.dart';
import '../../models/media_content.dart';
import '../../widgets/hero_banner.dart';
import '../../widgets/horizontal_shelf.dart';

class HomeMoviesScreen extends StatelessWidget {
  const HomeMoviesScreen({super.key});

  void _goToDetail(BuildContext context, MediaContent item) {
    Navigator.pushNamed(context, AppRoutes.movieDetail, arguments: item);
  }

  @override
  Widget build(BuildContext context) {
    final movies = MediaMock.movies;
    final publicDomain = movies.where((m) => m.publicDomain).toList();
    final streaming = movies.where((m) => !m.publicDomain).toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Banner com carousel
          CarouselSlider(
            options: CarouselOptions(
              height: 380,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 6),
              viewportFraction: 1.0,
            ),
            items: publicDomain.take(3).map((item) {
              return HeroBanner(
                content: item,
                onWatch: () => _goToDetail(context, item),
                onDetails: () => _goToDetail(context, item),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          HorizontalShelf(
            title: 'Domínio Público',
            items: publicDomain,
            onItemTap: (item) => _goToDetail(context, item),
          ),
          HorizontalShelf(
            title: 'Em Alta',
            items: movies,
            onItemTap: (item) => _goToDetail(context, item),
          ),
          HorizontalShelf(
            title: 'Streaming',
            items: streaming,
            onItemTap: (item) => _goToDetail(context, item),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
