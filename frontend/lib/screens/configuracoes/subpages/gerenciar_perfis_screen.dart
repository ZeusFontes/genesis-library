import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/colors.dart';
import '../../../mocks/profiles_mock.dart';
import '../../../models/profile.dart';

class GerenciarPerfisScreen extends StatefulWidget {
  const GerenciarPerfisScreen({super.key});

  @override
  State<GerenciarPerfisScreen> createState() => _GerenciarPerfisScreenState();
}

class _GerenciarPerfisScreenState extends State<GerenciarPerfisScreen> {
  late List<Profile> _profiles;
  bool _editMode = false;

  @override
  void initState() {
    super.initState();
    _profiles = List.from(ProfilesMock.profiles);
  }

  void _toggleEdit() => setState(() => _editMode = !_editMode);

  void _removerPerfil(Profile p) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Remover "${p.name}"?'),
        content: const Text(
          'O histórico e a lista deste perfil serão excluídos permanentemente.',
          style: TextStyle(color: AppColors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.softAccent)),
          ),
          TextButton(
            onPressed: () {
              setState(() => _profiles.removeWhere((x) => x.id == p.id));
              Navigator.pop(context);
            },
            child: const Text('Remover', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  void _adicionarPerfil() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Novo perfil'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            hintText: 'Nome do perfil',
            prefixIcon: Icon(Icons.person_outline, color: AppColors.grey),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.softAccent)),
          ),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isEmpty) return;
              setState(() {
                _profiles.add(Profile(
                  id: 'p${DateTime.now().millisecondsSinceEpoch}',
                  name: name,
                  avatar: 'https://api.dicebear.com/10.x/thumbs/png?seed=$name',
                ));
              });
              Navigator.pop(context);
            },
            child: const Text('Criar', style: TextStyle(color: AppColors.primaryAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar perfis'),
        actions: [
          TextButton(
            onPressed: _toggleEdit,
            child: Text(
              _editMode ? 'Concluir' : 'Editar',
              style: const TextStyle(color: AppColors.primaryAccent),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Gerencie quem tem acesso ao GÊNESIS neste dispositivo.',
              style: const TextStyle(color: AppColors.grey, fontSize: 13, height: 1.5),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _profiles.length + (_profiles.length < 5 ? 1 : 0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemBuilder: (_, i) {
                if (i == _profiles.length) {
                  return _AddProfileTile(onTap: _adicionarPerfil);
                }
                return _ProfileEditTile(
                  profile: _profiles[i],
                  editMode: _editMode,
                  onRemove: () => _removerPerfil(_profiles[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileEditTile extends StatelessWidget {
  final Profile profile;
  final bool editMode;
  final VoidCallback onRemove;

  const _ProfileEditTile({
    required this.profile,
    required this.editMode,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.secondary.withOpacity(0.5)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: profile.avatar,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => Container(
                    width: 80, height: 80,
                    color: AppColors.secondary,
                    child: Center(
                      child: Text(
                        profile.name[0],
                        style: const TextStyle(fontSize: 32, color: AppColors.white),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                profile.name,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              const Text('Perfil', style: TextStyle(color: AppColors.grey, fontSize: 11)),
            ],
          ),
        ),
        if (editMode)
          Positioned(
            top: -8,
            right: -8,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.background, width: 2),
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),
      ],
    );
  }
}

class _AddProfileTile extends StatelessWidget {
  final VoidCallback onTap;
  const _AddProfileTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primaryAccent.withOpacity(0.4),
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primaryAccent.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: AppColors.primaryAccent, size: 28),
            ),
            const SizedBox(height: 12),
            const Text(
              'Adicionar perfil',
              style: TextStyle(color: AppColors.primaryAccent, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
