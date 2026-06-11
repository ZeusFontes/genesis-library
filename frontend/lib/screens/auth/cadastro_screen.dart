import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/assets.dart';
import '../../core/constants/routes.dart';
import '../../services/api_service.dart';

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});
  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _nomeController           = TextEditingController();
  final _emailController          = TextEditingController();
  final _senhaController          = TextEditingController();
  final _confirmarSenhaController = TextEditingController();
  bool _obscureSenha     = true;
  bool _obscureConfirmar = true;
  bool _aceitouTermos    = false;
  bool _loading          = false;
  String? _senhaError;
  String? _apiError;

  @override
  void dispose() {
    _nomeController.dispose(); _emailController.dispose();
    _senhaController.dispose(); _confirmarSenhaController.dispose();
    super.dispose();
  }

  Future<void> _cadastrar() async {
    final senha    = _senhaController.text;
    final confirmar = _confirmarSenhaController.text;
    if (senha != confirmar) { setState(() => _senhaError = 'As senhas não coincidem'); return; }
    if (senha.length < 6)   { setState(() => _senhaError = 'Mínimo 6 caracteres'); return; }
    setState(() { _senhaError = null; _apiError = null; _loading = true; });
    try {
      final user = await ApiService.createUser(
        username: _nomeController.text.trim(),
        email: _emailController.text.trim(),
        passwordHash: ApiService.sha256Hash(senha),
      );
      if (!mounted) return;
      ApiService.currentUserId = user['id'] as int;
      // Novo usuário nunca tem perfis — vai direto para criar perfil
      Navigator.pushReplacementNamed(context, AppRoutes.criarPerfil);
    } on ApiException catch (e) {
      setState(() => _apiError = e.message);
    } catch (_) {
      setState(() => _apiError = 'Erro de conexão. Verifique se o backend está rodando.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(center: Alignment(-0.7, -0.8), radius: 1.2,
              colors: [AppColors.secondary, AppColors.background]),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Align(alignment: Alignment.topLeft,
                child: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.white),
                    onPressed: () => Navigator.pop(context))),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      Image.asset(AppAssets.logo, height: 80,
                        errorBuilder: (_, __, ___) => const Icon(Icons.movie_filter, size: 64, color: AppColors.primaryAccent)),
                      const SizedBox(height: 24),
                      const Text('Criar conta', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      const Text('Junte-se ao GÊNESIS', style: TextStyle(color: AppColors.grey, fontSize: 14)),
                      const SizedBox(height: 32),
                      TextField(controller: _nomeController, textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(hintText: 'Nome completo',
                              prefixIcon: Icon(Icons.person_outline, color: AppColors.grey))),
                      const SizedBox(height: 14),
                      TextField(controller: _emailController, keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(hintText: 'E-mail',
                              prefixIcon: Icon(Icons.email_outlined, color: AppColors.grey))),
                      const SizedBox(height: 14),
                      TextField(controller: _senhaController, obscureText: _obscureSenha,
                          decoration: InputDecoration(hintText: 'Senha',
                              prefixIcon: const Icon(Icons.lock_outline, color: AppColors.grey),
                              suffixIcon: IconButton(icon: Icon(_obscureSenha ? Icons.visibility_off : Icons.visibility, color: AppColors.grey),
                                  onPressed: () => setState(() => _obscureSenha = !_obscureSenha))),
                          onChanged: (_) => setState(() => _senhaError = null)),
                      const SizedBox(height: 14),
                      TextField(controller: _confirmarSenhaController, obscureText: _obscureConfirmar,
                          decoration: InputDecoration(hintText: 'Confirmar senha', errorText: _senhaError,
                              prefixIcon: const Icon(Icons.lock_outline, color: AppColors.grey),
                              suffixIcon: IconButton(icon: Icon(_obscureConfirmar ? Icons.visibility_off : Icons.visibility, color: AppColors.grey),
                                  onPressed: () => setState(() => _obscureConfirmar = !_obscureConfirmar))),
                          onChanged: (_) => setState(() => _senhaError = null)),
                      if (_apiError != null) ...[
                        const SizedBox(height: 12),
                        Text(_apiError!, style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
                      ],
                      const SizedBox(height: 20),
                      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Checkbox(value: _aceitouTermos, activeColor: AppColors.primaryAccent,
                            onChanged: (v) => setState(() => _aceitouTermos = v ?? false)),
                        Expanded(child: Padding(padding: const EdgeInsets.only(top: 12),
                          child: Wrap(children: [
                            const Text('Li e aceito os ', style: TextStyle(color: AppColors.grey, fontSize: 13)),
                            GestureDetector(onTap: () => Navigator.pushNamed(context, AppRoutes.termos),
                              child: const Text('Termos de Uso', style: TextStyle(color: AppColors.primaryAccent, fontSize: 13,
                                  decoration: TextDecoration.underline, decorationColor: AppColors.primaryAccent))),
                            const Text(' e a ', style: TextStyle(color: AppColors.grey, fontSize: 13)),
                            GestureDetector(onTap: () => Navigator.pushNamed(context, AppRoutes.privacidade),
                              child: const Text('Política de Privacidade', style: TextStyle(color: AppColors.primaryAccent, fontSize: 13,
                                  decoration: TextDecoration.underline, decorationColor: AppColors.primaryAccent))),
                          ]),
                        )),
                      ]),
                      const SizedBox(height: 24),
                      SizedBox(width: double.infinity,
                        child: ElevatedButton(
                          onPressed: (_aceitouTermos && !_loading) ? _cadastrar : null,
                          child: _loading
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                              : const Text('Criar conta'),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        const Text('Já tem uma conta? ', style: TextStyle(color: AppColors.grey)),
                        TextButton(onPressed: () => Navigator.pop(context),
                          child: const Text('Entrar', style: TextStyle(color: AppColors.primaryAccent))),
                      ]),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
