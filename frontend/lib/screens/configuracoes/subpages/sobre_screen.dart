import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/assets.dart';
import '../../../core/constants/routes.dart';

class SobreScreen extends StatelessWidget {
  const SobreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sobre o GÊNESIS')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40),
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.5),
                  radius: 1.2,
                  colors: [
                    AppColors.primaryAccent.withOpacity(0.15),
                    AppColors.background,
                  ],
                ),
              ),
              child: Column(
                children: [
                  Image.asset(
                    AppAssets.logo,
                    height: 100,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.movie_filter,
                      size: 80,
                      color: AppColors.primaryAccent,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'GÊNESIS',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 6,
                      color: AppColors.primaryAccent,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Versão 1.0.0',
                    style: TextStyle(color: AppColors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Missão
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.secondary.withOpacity(0.4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Row(
                          children: [
                            Icon(Icons.auto_awesome, color: AppColors.primaryAccent, size: 20),
                            SizedBox(width: 8),
                            Text('Nossa missão', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        SizedBox(height: 12),
                        Text(
                          'O GÊNESIS nasceu para democratizar o acesso à cultura. Reunimos filmes, séries e livros de domínio público — obras que pertencem à humanidade — em um só lugar, gratuito e sem anúncios.',
                          style: TextStyle(color: AppColors.softAccent, fontSize: 13, height: 1.7),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Para conteúdos modernos, direcionamos você às plataformas corretas de forma rápida e organizada.',
                          style: TextStyle(color: AppColors.softAccent, fontSize: 13, height: 1.7),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Stats
                  Row(
                    children: const [
                      Expanded(child: _StatCard(valor: '500+', label: 'Filmes')),
                      SizedBox(width: 12),
                      Expanded(child: _StatCard(valor: '1.200+', label: 'Livros')),
                      SizedBox(width: 12),
                      Expanded(child: _StatCard(valor: '100%', label: 'Gratuito')),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Tecnologias
                  const Text('Tecnologia', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: const [
                      _TechChip('Flutter'),
                      _TechChip('Dart'),
                      _TechChip('Archive.org'),
                      _TechChip('Project Gutenberg'),
                      _TechChip('DiceBear API'),
                      _TechChip('Google Fonts'),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Links legais
                  const Text('Legal', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _LinkTile(
                    icon: Icons.description_outlined,
                    title: 'Termos de Uso',
                    onTap: () => Navigator.pushNamed(context, AppRoutes.termos),
                  ),
                  _LinkTile(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Política de Privacidade',
                    onTap: () => Navigator.pushNamed(context, AppRoutes.privacidade),
                  ),
                  _LinkTile(
                    icon: Icons.gavel_outlined,
                    title: 'Licenças de software',
                    onTap: () => showLicensePage(
                      context: context,
                      applicationName: 'GÊNESIS',
                      applicationVersion: '1.0.0',
                    ),
                  ),

                  const SizedBox(height: 24),

                  Center(
                    child: Column(
                      children: const [
                        Text(
                          'Feito com ❤️ para os amantes de cultura',
                          style: TextStyle(color: AppColors.grey, fontSize: 12),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '© 2025 GÊNESIS. Todos os direitos reservados.',
                          style: TextStyle(color: AppColors.secondary, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
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

class _StatCard extends StatelessWidget {
  final String valor;
  final String label;

  const _StatCard({required this.valor, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.secondary.withOpacity(0.4)),
      ),
      child: Column(
        children: [
          Text(
            valor,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryAccent,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: AppColors.grey, fontSize: 11)),
        ],
      ),
    );
  }
}

class _TechChip extends StatelessWidget {
  final String label;
  const _TechChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.secondary),
      ),
      child: Text(label, style: const TextStyle(color: AppColors.softAccent, fontSize: 12)),
    );
  }
}

class _LinkTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _LinkTile({required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.secondary.withOpacity(0.4)),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.softAccent, size: 20),
        title: Text(title, style: const TextStyle(fontSize: 14)),
        trailing: const Icon(Icons.chevron_right, color: AppColors.grey, size: 20),
        onTap: onTap,
      ),
    );
  }
}
