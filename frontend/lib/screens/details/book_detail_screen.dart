import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/colors.dart';
import '../home/home_books_screen.dart';

class BookDetailScreen extends StatelessWidget {
  const BookDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final book = ModalRoute.of(context)!.settings.arguments as BookItem;

    return Scaffold(
      appBar: AppBar(
        title: Text(book.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Capa + Info
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: book.cover,
                    width: 120,
                    height: 175,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => Container(
                      width: 120, height: 175,
                      color: AppColors.secondary,
                      child: const Icon(Icons.menu_book, color: AppColors.white, size: 48),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(book.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text(book.author, style: const TextStyle(color: AppColors.softAccent, fontSize: 15)),
                      const SizedBox(height: 10),
                      _Badge(book.genre, AppColors.secondary),
                      const SizedBox(height: 6),
                      _Badge(
                        book.publicDomain ? '✓ Domínio Público' : 'Requer Compra',
                        book.publicDomain ? AppColors.primaryAccent : AppColors.grey,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Sinopse
            const Text('Sobre o Livro', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(book.synopsis, style: const TextStyle(color: AppColors.grey, fontSize: 14, height: 1.7)),

            const SizedBox(height: 28),

            // REGRA DE NEGÓCIO: domínio público vs pago
            if (book.publicDomain) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Iniciando download...')),
                    );
                  },
                  icon: const Icon(Icons.download),
                  label: const Text('Baixar PDF Grátis'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Abrindo leitor...')),
                    );
                  },
                  icon: const Icon(Icons.menu_book),
                  label: const Text('Ler Agora'),
                ),
              ),
            ] else
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primaryAccent),
                    foregroundColor: AppColors.primaryAccent,
                  ),
                  onPressed: () {},
                  icon: const Icon(Icons.shopping_cart_outlined),
                  label: const Text('Onde Comprar'),
                ),
              ),

            const SizedBox(height: 40),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        border: Border.all(color: color.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 12)),
    );
  }
}
