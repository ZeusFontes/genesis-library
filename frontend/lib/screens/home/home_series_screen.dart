import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../core/constants/routes.dart';
import '../../mocks/media_mock.dart';
import '../../models/media_content.dart';
import '../../widgets/hero_banner.dart';
import '../../widgets/horizontal_shelf.dart';

class HomeSeriesScreen extends StatelessWidget {
  const HomeSeriesScreen({super.key});

  void _goToDetail(BuildContext context, MediaContent item) {
    Navigator.pushNamed(context, AppRoutes.movieDetail, arguments: item);
  }

  @override
  Widget build(BuildContext context) {
    final series = MediaMock.series;
    final topRated = [...series]..sort((a, b) => b.imdb.compareTo(a.imdb));

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CarouselSlider(
            options: CarouselOptions(
              height: 380,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 7),
              viewportFraction: 1.0,
            ),
            items: series.take(2).map((item) {
              return HeroBanner(
                content: item,
                onWatch: () => _goToDetail(context, item),
                onDetails: () => _goToDetail(context, item),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          HorizontalShelf(
            title: 'Séries em Destaque',
            items: series,
            onItemTap: (item) => _goToDetail(context, item),
          ),
          HorizontalShelf(
            title: 'Melhor Avaliadas',
            items: topRated,
            onItemTap: (item) => _goToDetail(context, item),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
