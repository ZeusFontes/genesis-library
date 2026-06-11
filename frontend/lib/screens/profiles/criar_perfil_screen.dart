import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/routes.dart';
import '../../services/api_service.dart';

class CriarPerfilScreen extends StatefulWidget {
  const CriarPerfilScreen({super.key});

  @override
  State<CriarPerfilScreen> createState() => _CriarPerfilScreenState();
}

class _CriarPerfilScreenState extends State<CriarPerfilScreen> {
  final _nomeController = TextEditingController();
  bool _loading = false;
  String? _error;

  // Avatares gerados via DiceBear
  final _avatarSeeds = [
    'Felix',
    'Luna',
    'Max',
  ];
  String _selectedSeed = 'Felix';

  String _avatarUrl(String seed) =>
      'https://api.dicebear.com/9.x/thumbs/png?seed=${Uri.encodeComponent(seed)}';

  Future<void> _criar() async {
    final nome = _nomeController.text.trim();
    if (nome.isEmpty) {
      setState(() => _error = 'Digite um nome para o perfil.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await ApiService.createProfile(
        userId: ApiService.currentUserId!,
        name: nome,
        avatarUrl: _avatarUrl(_selectedSeed),
      );

      if (!mounted) return;
      Navigator.pop(context);
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'Erro ao criar perfil. Tente novamente.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Novo Perfil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Escolha um avatar',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 90,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _avatarSeeds.length,
                itemBuilder: (_, i) {
                  final seed = _avatarSeeds[i];
                  final selected = seed == _selectedSeed;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedSeed = seed),
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected
                              ? AppColors.primaryAccent
                              : AppColors.secondary,
                          width: selected ? 3 : 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          _avatarUrl(seed),
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 80,
                            height: 80,
                            color: AppColors.secondary,
                            child: const Icon(Icons.person,
                                color: AppColors.white),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
            const Text('Nome do perfil',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: _nomeController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                hintText: 'Ex: Quarto, Kids, Trabalho...',
                prefixIcon: Icon(Icons.person_outline, color: AppColors.grey),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: Colors.redAccent)),
            ],
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _criar,
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.black))
                    : const Text('Criar Perfil'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
