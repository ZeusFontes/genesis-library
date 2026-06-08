import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import '../core/constants/routes.dart';
import '../screens/home/home_movies_screen.dart';
import '../screens/home/home_series_screen.dart';
import '../screens/home/home_books_screen.dart';
import '../screens/addons/addons_screen.dart';
import '../screens/profile/profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final _pages = const [
    HomeMoviesScreen(),
    HomeSeriesScreen(),
    HomeBooksScreen(),
    AddonsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _currentIndex == 0
            ? const Text('Filmes')
            : _currentIndex == 1
                ? const Text('Séries')
                : _currentIndex == 2
                    ? const Text('Livros')
                    : _currentIndex == 3
                        ? const Text('Addons')
                        : const Text('Perfil'),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            'assets/logo/genesis_logo.png',
            errorBuilder: (_, __, ___) => const Icon(
              Icons.movie_filter,
              color: AppColors.primaryAccent,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.white),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.busca),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: AppColors.white),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.notificacoes),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.movie_outlined),
            activeIcon: Icon(Icons.movie),
            label: 'Filmes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.tv_outlined),
            activeIcon: Icon(Icons.tv),
            label: 'Séries',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined),
            activeIcon: Icon(Icons.menu_book),
            label: 'Livros',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.extension_outlined),
            activeIcon: Icon(Icons.extension),
            label: 'Addons',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
