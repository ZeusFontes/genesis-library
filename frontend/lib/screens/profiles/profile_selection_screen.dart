import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/routes.dart';
import '../../mocks/profiles_mock.dart';
import '../../models/profile.dart';

class ProfileSelectionScreen extends StatelessWidget {
  const ProfileSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profiles = ProfilesMock.profiles;

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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Quem está assistindo?',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Selecione seu perfil',
                style: TextStyle(color: AppColors.grey, fontSize: 14),
              ),
              const SizedBox(height: 48),
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
                    return _ProfileTile(
                      isAdd: true,
                      onTap: () {},
                    );
                  }
                  return _ProfileTile(
                    profile: profiles[index],
                    onTap: () => Navigator.pushReplacementNamed(
                      context,
                      AppRoutes.home,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final Profile? profile;
  final bool isAdd;
  final VoidCallback onTap;

  const _ProfileTile({this.profile, this.isAdd = false, required this.onTap});

  @override
  Widget build(BuildContext context) {
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
                      imageUrl: profile!.avatar,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Container(
                        width: 120,
                        height: 120,
                        color: AppColors.secondary,
                        child: Center(
                          child: Text(
                            profile!.name[0],
                            style: const TextStyle(fontSize: 40, color: AppColors.white),
                          ),
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            isAdd ? '+ Novo Perfil' : profile!.name,
            style: const TextStyle(fontSize: 15),
          ),
        ],
      ),
    );
  }
}
