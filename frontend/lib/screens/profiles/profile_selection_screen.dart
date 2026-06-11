import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/routes.dart';
import '../../services/api_service.dart';

class ProfileSelectionScreen extends StatefulWidget {
  const ProfileSelectionScreen({super.key});

  @override
  State<ProfileSelectionScreen> createState() => _ProfileSelectionScreenState();
}

class _ProfileSelectionScreenState extends State<ProfileSelectionScreen> {
  late Future<List<Map<String, dynamic>>> _profilesFuture;

  @override
  void initState() {
    super.initState();
    _profilesFuture = _loadProfiles();
  }

  Future<List<Map<String, dynamic>>> _loadProfiles() async {
    final userId = ApiService.currentUserId;
    if (userId == null) return [];
    return ApiService.fetchProfiles(userId);
  }

  void _selectProfile(Map<String, dynamic> profile) {
    ApiService.currentProfileId   = profile['id'] as int;
    ApiService.currentProfileName = profile['name'] as String? ?? '';
    ApiService.currentProfileAvatar =
        profile['avatar_url'] as String? ?? '';
    Navigator.pushReplacementNamed(context, AppRoutes.home);
  }

  void _goToCreateProfile() {
    Navigator.pushNamed(context, AppRoutes.criarPerfil).then((_) {
      setState(() => _profilesFuture = _loadProfiles());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.5),
            radius: 1.0,
            colors: [AppColors.secondary, AppColors.background],
          ),
        ),
        child: SafeArea(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _profilesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final profiles = snapshot.data ?? [];

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Quem está assistindo?',
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Selecione seu perfil',
                      style: TextStyle(color: AppColors.grey, fontSize: 14)),
                  const SizedBox(height: 48),

                  if (profiles.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          const Text(
                            'Nenhum perfil encontrado.\nCrie seu primeiro perfil para continuar.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.grey),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: _goToCreateProfile,
                            icon: const Icon(Icons.add),
                            label: const Text('Criar Perfil'),
                          ),
                        ],
                      ),
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      itemCount: profiles.length + 1,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.8,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemBuilder: (context, index) {
                        if (index == profiles.length) {
                          return _ProfileTile(isAdd: true, onTap: _goToCreateProfile);
                        }
                        return _ProfileTile(
                          profile: profiles[index],
                          onTap: () => _selectProfile(profiles[index]),
                        );
                      },
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final Map<String, dynamic>? profile;
  final bool isAdd;
  final VoidCallback onTap;

  const _ProfileTile({this.profile, this.isAdd = false, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final name = profile?['name'] as String? ?? '';
    final avatarSeed = Uri.encodeComponent(name.isNotEmpty ? name : 'user');
    final avatarUrl = profile?['avatar_url'] as String? ??
        'https://api.dicebear.com/9.x/thumbs/png?seed=$avatarSeed';

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.secondary, width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: isAdd
                  ? Container(
                      width: 120,
                      height: 120,
                      color: AppColors.surface,
                      child: const Icon(Icons.add, size: 48, color: AppColors.softAccent),
                    )
                  : CachedNetworkImage(
                      imageUrl: avatarUrl,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Container(
                        width: 120,
                        height: 120,
                        color: AppColors.secondary,
                        child: Center(
                          child: Text(
                            name.isNotEmpty ? name[0].toUpperCase() : '?',
                            style: const TextStyle(fontSize: 40, color: AppColors.white),
                          ),
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          Text(isAdd ? '+ Novo Perfil' : name,
              style: const TextStyle(fontSize: 15)),
        ],
      ),
    );
  }
}
