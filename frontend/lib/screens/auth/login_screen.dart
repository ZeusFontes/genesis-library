import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/assets.dart';
import '../../core/constants/routes.dart';
import '../../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _loading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email    = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Preencha e-mail e senha.');
      return;
    }
    setState(() { _loading = true; _errorMessage = null; });
    try {
      final user = await ApiService.loginUser(
        email: email,
        passwordHash: ApiService.sha256Hash(password),
      );
      if (!mounted) return;
      ApiService.currentUserId = user['id'] as int;

      // Verifica se tem perfis
      final profiles = await ApiService.fetchProfiles(ApiService.currentUserId!);
      if (!mounted) return;

      if (profiles.isEmpty) {
        Navigator.pushReplacementNamed(context, AppRoutes.criarPerfil);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.profiles);
      }
    } on ApiException catch (e) {
      setState(() => _errorMessage = e.message);
    } on TimeoutException {
      setState(() => _errorMessage =
          'Tempo esgotado. Verifique se o backend está rodando e se o IP está correto.');
    } catch (_) {
      setState(() => _errorMessage =
          'Erro de conexão. Backend offline ou IP incorreto (dispositivo físico precisa do IP da máquina).');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.7, -0.8),
            radius: 1.2,
            colors: [AppColors.secondary, AppColors.background],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(AppAssets.logo, height: 120,
                    errorBuilder: (_, __, ___) => const Column(children: [
                      Icon(Icons.movie_filter, size: 80, color: AppColors.primaryAccent),
                      SizedBox(height: 8),
                      Text('GÊNESIS', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 6, color: AppColors.primaryAccent)),
                    ]),
                  ),
                  const SizedBox(height: 12),
                  const Text('GÊNESIS', style: TextStyle(color: AppColors.softAccent, fontSize: 12, letterSpacing: 8)),
                  const SizedBox(height: 48),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(hintText: 'E-mail', prefixIcon: Icon(Icons.email_outlined, color: AppColors.grey)),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText: 'Senha',
                      prefixIcon: const Icon(Icons.lock_outline, color: AppColors.grey),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: AppColors.grey),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(_errorMessage!, style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
                  ],
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.pushNamed(context, AppRoutes.esqueciSenha),
                      child: const Text('Esqueci minha senha', style: TextStyle(color: AppColors.softAccent)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _login,
                      child: _loading
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                          : const Text('Entrar'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Não tem conta? ', style: TextStyle(color: AppColors.grey)),
                      TextButton(
                        onPressed: () => Navigator.pushNamed(context, AppRoutes.cadastro),
                        child: const Text('Cadastre-se', style: TextStyle(color: AppColors.primaryAccent)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
