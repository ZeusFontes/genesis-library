import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/routes.dart';

class BookItem {
  final String id;
  final String title;
  final String author;
  final String cover;
  final String synopsis;
  final bool publicDomain;
  final String genre;

  BookItem({
    required this.id,
    required this.title,
    required this.author,
    required this.cover,
    required this.synopsis,
    required this.publicDomain,
    required this.genre,
  });
}

final mockBooks = [
  BookItem(id: 'b1', title: 'Dom Quixote', author: 'Cervantes', cover: 'https://picsum.photos/seed/dq/200/300', synopsis: 'As aventuras do cavaleiro da triste figura.', publicDomain: true, genre: 'Clássico'),
  BookItem(id: 'b2', title: 'Crime e Castigo', author: 'Dostoiévski', cover: 'https://picsum.photos/seed/cc/200/300', synopsis: 'O dilema moral de um jovem estudante em São Petersburgo.', publicDomain: true, genre: 'Clássico'),
  BookItem(id: 'b3', title: 'Moby Dick', author: 'Melville', cover: 'https://picsum.photos/seed/md/200/300', synopsis: 'A obsessão do Capitão Ahab pela grande baleia branca.', publicDomain: true, genre: 'Aventura'),
  BookItem(id: 'b4', title: 'O Senhor dos Anéis', author: 'Tolkien', cover: 'https://picsum.photos/seed/lotr/200/300', synopsis: 'A grande jornada para destruir o Um Anel.', publicDomain: false, genre: 'Fantasia'),
  BookItem(id: 'b5', title: 'Cem Anos de Solidão', author: 'García Márquez', cover: 'https://picsum.photos/seed/cem/200/300', synopsis: 'A saga da família Buendía em Macondo.', publicDomain: false, genre: 'Realismo Mágico'),
];

class HomeBooksScreen extends StatelessWidget {
  const HomeBooksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final publicDomain = mockBooks.where((b) => b.publicDomain).toList();
    final all = mockBooks;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Biblioteca GÊNESIS', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text('Clássicos da literatura e muito mais', style: TextStyle(color: AppColors.grey, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _BookShelf(title: 'Domínio Público — Grátis', books: publicDomain),
          _BookShelf(title: 'Toda a Biblioteca', books: all),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _BookShelf extends StatelessWidget {
  final String title;
  final List<BookItem> books;

  const _BookShelf({required this.title, required this.books});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        SizedBox(
          height: 260,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: books.length,
            itemBuilder: (_, i) => _BookCard(book: books[i]),
          ),
        ),
      ],
    );
  }
}

class _BookCard extends StatelessWidget {
  final BookItem book;

  const _BookCard({required this.book});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.bookDetail, arguments: book),
      child: Container(
        width: 130,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.secondary.withOpacity(0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              child: CachedNetworkImage(
                imageUrl: book.cover,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Container(
                  height: 180,
                  color: AppColors.secondary,
                  child: const Icon(Icons.menu_book, color: AppColors.white, size: 48),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(book.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 3),
                  Text(book.author, style: const TextStyle(color: AppColors.softAccent, fontSize: 11)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: book.publicDomain ? AppColors.primaryAccent.withOpacity(0.15) : AppColors.secondary.withOpacity(0.3),
                      border: Border.all(color: book.publicDomain ? AppColors.primaryAccent.withOpacity(0.5) : AppColors.secondary.withOpacity(0.5)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      book.publicDomain ? 'Grátis' : 'Comprar',
                      style: TextStyle(fontSize: 9, color: book.publicDomain ? AppColors.primaryAccent : AppColors.grey),
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
}
