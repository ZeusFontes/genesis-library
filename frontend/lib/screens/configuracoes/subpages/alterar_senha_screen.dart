import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';

class AlterarSenhaScreen extends StatefulWidget {
  const AlterarSenhaScreen({super.key});

  @override
  State<AlterarSenhaScreen> createState() => _AlterarSenhaScreenState();
}

class _AlterarSenhaScreenState extends State<AlterarSenhaScreen> {
  final _atualController = TextEditingController();
  final _novaController = TextEditingController();
  final _confirmarController = TextEditingController();
  bool _obscureAtual = true;
  bool _obscureNova = true;
  bool _obscureConfirmar = true;
  bool _loading = false;
  String? _error;

  int get _forca {
    final s = _novaController.text;
    if (s.isEmpty) return 0;
    int score = 0;
    if (s.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(s)) score++;
    if (RegExp(r'[0-9]').hasMatch(s)) score++;
    if (RegExp(r'[!@#\$%^&*]').hasMatch(s)) score++;
    return score;
  }

  Color get _forcaCor {
    if (_forca <= 1) return Colors.redAccent;
    if (_forca == 2) return Colors.orangeAccent;
    if (_forca == 3) return Colors.yellowAccent;
    return Colors.greenAccent;
  }

  String get _forcaLabel {
    if (_forca <= 1) return 'Fraca';
    if (_forca == 2) return 'Razoável';
    if (_forca == 3) return 'Boa';
    return 'Forte';
  }

  void _salvar() async {
    final nova = _novaController.text;
    final confirmar = _confirmarController.text;

    if (nova != confirmar) {
      setState(() => _error = 'As senhas não coincidem');
      return;
    }
    if (nova.length < 6) {
      setState(() => _error = 'A nova senha deve ter pelo menos 6 caracteres');
      return;
    }

    setState(() { _error = null; _loading = true; });
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Senha alterada com sucesso!'),
        backgroundColor: AppColors.surface,
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alterar senha')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Aviso de segurança
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primaryAccent.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primaryAccent.withOpacity(0.3)),
              ),
              child: Row(
                children: const [
                  Icon(Icons.shield_outlined, color: AppColors.primaryAccent, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Use uma senha forte com letras maiúsculas, números e símbolos.',
                      style: TextStyle(color: AppColors.softAccent, fontSize: 13, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            const Text('Senha atual', style: TextStyle(fontSize: 13, color: AppColors.grey)),
            const SizedBox(height: 8),
            TextField(
              controller: _atualController,
              obscureText: _obscureAtual,
              decoration: InputDecoration(
                hintText: 'Digite sua senha atual',
                prefixIcon: const Icon(Icons.lock_outline, color: AppColors.grey),
                suffixIcon: IconButton(
                  icon: Icon(_obscureAtual ? Icons.visibility_off : Icons.visibility, color: AppColors.grey),
                  onPressed: () => setState(() => _obscureAtual = !_obscureAtual),
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Text('Nova senha', style: TextStyle(fontSize: 13, color: AppColors.grey)),
            const SizedBox(height: 8),
            TextField(
              controller: _novaController,
              obscureText: _obscureNova,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Digite a nova senha',
                prefixIcon: const Icon(Icons.lock_outline, color: AppColors.grey),
                suffixIcon: IconButton(
                  icon: Icon(_obscureNova ? Icons.visibility_off : Icons.visibility, color: AppColors.grey),
                  onPressed: () => setState(() => _obscureNova = !_obscureNova),
                ),
              ),
            ),

            // Indicador de força
            if (_novaController.text.isNotEmpty) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _forca / 4,
                        backgroundColor: AppColors.secondary,
                        valueColor: AlwaysStoppedAnimation<Color>(_forcaCor),
                        minHeight: 4,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(_forcaLabel, style: TextStyle(color: _forcaCor, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Use 8+ caracteres, maiúsculas, números e símbolos (!@#\$)',
                style: TextStyle(color: AppColors.grey, fontSize: 11),
              ),
            ],

            const SizedBox(height: 20),
            const Text('Confirmar nova senha', style: TextStyle(fontSize: 13, color: AppColors.grey)),
            const SizedBox(height: 8),
            TextField(
              controller: _confirmarController,
              obscureText: _obscureConfirmar,
              onChanged: (_) => setState(() => _error = null),
              decoration: InputDecoration(
                hintText: 'Repita a nova senha',
                prefixIcon: const Icon(Icons.lock_outline, color: AppColors.grey),
                errorText: _error,
                suffixIcon: IconButton(
                  icon: Icon(_obscureConfirmar ? Icons.visibility_off : Icons.visibility, color: AppColors.grey),
                  onPressed: () => setState(() => _obscureConfirmar = !_obscureConfirmar),
                ),
              ),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _salvar,
                child: _loading
                    ? const SizedBox(
                        height: 20, width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                      )
                    : const Text('Salvar nova senha'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
