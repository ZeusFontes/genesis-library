import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/assets.dart';
import '../../core/constants/routes.dart';

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();
  bool _obscureSenha = true;
  bool _obscureConfirmar = true;
  bool _aceitouTermos = false;
  bool _loading = false;

  String? _senhaError;

  void _cadastrar() async {
    final senha = _senhaController.text;
    final confirmar = _confirmarSenhaController.text;

    if (senha != confirmar) {
      setState(() => _senhaError = 'As senhas não coincidem');
      return;
    }
    if (senha.length < 6) {
      setState(() => _senhaError = 'A senha deve ter pelo menos 6 caracteres');
      return;
    }
    setState(() {
      _senhaError = null;
      _loading = true;
    });
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.pushReplacementNamed(context, AppRoutes.profiles);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(-0.7, -0.8),
            radius: 1.2,
            colors: [AppColors.secondary, AppColors.background],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        AppAssets.logo,
                        height: 80,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.movie_filter,
                          size: 64,
                          color: AppColors.primaryAccent,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Criar conta',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Junte-se ao GÊNESIS',
                        style: TextStyle(color: AppColors.grey, fontSize: 14),
                      ),
                      const SizedBox(height: 32),

                      // Nome
                      TextField(
                        controller: _nomeController,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          hintText: 'Nome completo',
                          prefixIcon: Icon(Icons.person_outline, color: AppColors.grey),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Email
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          hintText: 'E-mail',
                          prefixIcon: Icon(Icons.email_outlined, color: AppColors.grey),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Senha
                      TextField(
                        controller: _senhaController,
                        obscureText: _obscureSenha,
                        decoration: InputDecoration(
                          hintText: 'Senha',
                          prefixIcon: const Icon(Icons.lock_outline, color: AppColors.grey),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureSenha ? Icons.visibility_off : Icons.visibility,
                              color: AppColors.grey,
                            ),
                            onPressed: () => setState(() => _obscureSenha = !_obscureSenha),
                          ),
                        ),
                        onChanged: (_) => setState(() => _senhaError = null),
                      ),
                      const SizedBox(height: 14),

                      // Confirmar senha
                      TextField(
                        controller: _confirmarSenhaController,
                        obscureText: _obscureConfirmar,
                        decoration: InputDecoration(
                          hintText: 'Confirmar senha',
                          prefixIcon: const Icon(Icons.lock_outline, color: AppColors.grey),
                          errorText: _senhaError,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmar ? Icons.visibility_off : Icons.visibility,
                              color: AppColors.grey,
                            ),
                            onPressed: () => setState(() => _obscureConfirmar = !_obscureConfirmar),
                          ),
                        ),
                        onChanged: (_) => setState(() => _senhaError = null),
                      ),
                      const SizedBox(height: 20),

                      // Aceite dos termos
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Checkbox(
                            value: _aceitouTermos,
                            activeColor: AppColors.primaryAccent,
                            onChanged: (v) => setState(() => _aceitouTermos = v ?? false),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Wrap(
                                children: [
                                  const Text(
                                    'Li e aceito os ',
                                    style: TextStyle(color: AppColors.grey, fontSize: 13),
                                  ),
                                  GestureDetector(
                                    onTap: () => Navigator.pushNamed(context, AppRoutes.termos),
                                    child: const Text(
                                      'Termos de Uso',
                                      style: TextStyle(
                                        color: AppColors.primaryAccent,
                                        fontSize: 13,
                                        decoration: TextDecoration.underline,
                                        decorationColor: AppColors.primaryAccent,
                                      ),
                                    ),
                                  ),
                                  const Text(
                                    ' e a ',
                                    style: TextStyle(color: AppColors.grey, fontSize: 13),
                                  ),
                                  GestureDetector(
                                    onTap: () => Navigator.pushNamed(context, AppRoutes.privacidade),
                                    child: const Text(
                                      'Política de Privacidade',
                                      style: TextStyle(
                                        color: AppColors.primaryAccent,
                                        fontSize: 13,
                                        decoration: TextDecoration.underline,
                                        decorationColor: AppColors.primaryAccent,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _aceitouTermos && !_loading ? _cadastrar : null,
                          child: _loading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                                )
                              : const Text('Criar conta'),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Já tem uma conta? ',
                            style: TextStyle(color: AppColors.grey),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              'Entrar',
                              style: TextStyle(color: AppColors.primaryAccent),
                            ),
                          ),
                        ],
                      ),
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
