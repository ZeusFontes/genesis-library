import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/routes.dart';
import '../../services/api_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final name   = ApiService.currentProfileName.isNotEmpty
        ? ApiService.currentProfileName
        : 'Perfil';
    final seed   = Uri.encodeComponent(name);
    final avatar = ApiService.currentProfileAvatar.isNotEmpty
        ? ApiService.currentProfileAvatar
        : 'https://api.dicebear.com/9.x/thumbs/png?seed=$seed';

    final menuItems = [
      (Icons.bookmark_outline,       'Minha Lista',      AppRoutes.minhaLista),
      (Icons.history,                 'Histórico',        AppRoutes.historico),
      (Icons.download_outlined,       'Downloads',        AppRoutes.downloads),
      (Icons.notifications_outlined,  'Notificações',     AppRoutes.notificacoes),
      (Icons.settings_outlined,       'Configurações',    AppRoutes.configuracoes),
      (Icons.help_outline,            'Ajuda',            AppRoutes.ajuda),
      (Icons.info_outline,            'Sobre o GÊNESIS',  AppRoutes.sobre),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Card do perfil
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.secondary),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.secondary, AppColors.surface],
                  stops: [0.0, 0.5],
                ),
              ),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primaryAccent, width: 3),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(13),
                      child: CachedNetworkImage(
                        imageUrl: avatar,
                        width: 90,
                        height: 90,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => Container(
                          width: 90, height: 90,
                          color: AppColors.secondary,
                          child: Center(
                            child: Text(
                              name.isNotEmpty ? name[0].toUpperCase() : '?',
                              style: const TextStyle(fontSize: 36, color: AppColors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(name,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryAccent.withOpacity(0.2),
                      border: Border.all(color: AppColors.primaryAccent.withOpacity(0.5)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('GÊNESIS Premium',
                        style: TextStyle(
                            color: AppColors.primaryAccent, fontSize: 12, letterSpacing: 1)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Trocar perfil
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primaryAccent.withOpacity(0.4)),
              ),
              child: ListTile(
                leading: const Icon(Icons.switch_account, color: AppColors.primaryAccent),
                title: const Text('Trocar Perfil'),
                trailing: const Icon(Icons.chevron_right, color: AppColors.grey),
                onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.profiles),
              ),
            ),

            // Menu items
            ...menuItems.map((item) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.secondary.withOpacity(0.4)),
                  ),
                  child: ListTile(
                    leading: Icon(item.$1, color: AppColors.softAccent),
                    title: Text(item.$2),
                    trailing: const Icon(Icons.chevron_right, color: AppColors.grey),
                    onTap: () {
                      Navigator.pushNamed(context, item.$3);
                    },
                  ),
                )),

            const SizedBox(height: 8),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.redAccent),
                  foregroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  ApiService.currentUserId      = null;
                  ApiService.currentProfileId   = null;
                  ApiService.currentProfileName = '';
                  ApiService.currentProfileAvatar = '';
                  Navigator.pushReplacementNamed(context, AppRoutes.login);
                },
                icon: const Icon(Icons.logout),
                label: const Text('Sair da conta'),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
