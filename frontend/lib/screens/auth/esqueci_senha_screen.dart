import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/assets.dart';

class EsqueciSenhaScreen extends StatefulWidget {
  const EsqueciSenhaScreen({super.key});

  @override
  State<EsqueciSenhaScreen> createState() => _EsqueciSenhaScreenState();
}

class _EsqueciSenhaScreenState extends State<EsqueciSenhaScreen> {
  final _emailController = TextEditingController();
  bool _enviado = false;
  bool _loading = false;

  void _enviar() async {
    if (_emailController.text.trim().isEmpty) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _loading = false;
      _enviado = true;
    });
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
          child: Column(
            children: [
              // Botão voltar
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: _enviado ? _SuccessView(email: _emailController.text.trim()) : _FormView(
                      emailController: _emailController,
                      loading: _loading,
                      onEnviar: _enviar,
                    ),
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

class _FormView extends StatelessWidget {
  final TextEditingController emailController;
  final bool loading;
  final VoidCallback onEnviar;

  const _FormView({
    required this.emailController,
    required this.loading,
    required this.onEnviar,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
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
        const SizedBox(height: 40),
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.primaryAccent.withOpacity(0.12),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primaryAccent.withOpacity(0.4)),
          ),
          child: const Icon(Icons.lock_reset, color: AppColors.primaryAccent, size: 32),
        ),
        const SizedBox(height: 24),
        const Text(
          'Esqueceu sua senha?',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Informe seu e-mail e enviaremos\nas instruções para redefinir sua senha.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.grey, fontSize: 14, height: 1.5),
        ),
        const SizedBox(height: 32),
        TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            hintText: 'Seu e-mail',
            prefixIcon: Icon(Icons.email_outlined, color: AppColors.grey),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: loading ? null : onEnviar,
            child: loading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.black,
                    ),
                  )
                : const Text('Enviar instruções'),
          ),
        ),
      ],
    );
  }
}

class _SuccessView extends StatelessWidget {
  final String email;
  const _SuccessView({required this.email});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.greenAccent.withOpacity(0.12),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.greenAccent.withOpacity(0.4)),
          ),
          child: const Icon(Icons.mark_email_read_outlined, color: Colors.greenAccent, size: 40),
        ),
        const SizedBox(height: 24),
        const Text(
          'E-mail enviado!',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text(
          'Enviamos as instruções para\n$email',
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.grey, fontSize: 14, height: 1.6),
        ),
        const SizedBox(height: 8),
        const Text(
          'Verifique também sua caixa de spam.',
          style: TextStyle(color: AppColors.softAccent, fontSize: 13),
        ),
        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Voltar ao login'),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Não recebi o e-mail',
            style: TextStyle(color: AppColors.softAccent),
          ),
        ),
      ],
    );
  }
}
