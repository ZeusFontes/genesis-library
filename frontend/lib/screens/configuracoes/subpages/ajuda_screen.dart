import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';

class _Faq {
  final String pergunta;
  final String resposta;
  bool aberto;

  _Faq({required this.pergunta, required this.resposta, this.aberto = false});
}

class AjudaScreen extends StatefulWidget {
  const AjudaScreen({super.key});

  @override
  State<AjudaScreen> createState() => _AjudaScreenState();
}

class _AjudaScreenState extends State<AjudaScreen> {
  final _faqs = [
    _Faq(
      pergunta: 'O que é domínio público?',
      resposta: 'Conteúdo de domínio público é aquele cujos direitos autorais expiraram ou nunca existiram, podendo ser acessado, reproduzido e distribuído livremente. No Brasil, obras entram em domínio público 70 anos após a morte do autor.',
    ),
    _Faq(
      pergunta: 'Como funciona o streaming externo?',
      resposta: 'Para conteúdos não-públicos (como filmes recentes e séries), o GÊNESIS exibe informações e redireciona você para a plataforma de streaming onde o conteúdo está disponível (Netflix, Amazon, HBO etc.). Você precisará de uma assinatura ativa nessa plataforma.',
    ),
    _Faq(
      pergunta: 'Posso assistir offline?',
      resposta: 'Sim! Conteúdos de domínio público podem ser baixados para assistir sem conexão com a internet. Vá em Perfil → Downloads para gerenciar seus downloads. O conteúdo de streaming externo não pode ser baixado pelo GÊNESIS.',
    ),
    _Faq(
      pergunta: 'Como adicionar conteúdo à Minha Lista?',
      resposta: 'Na tela de detalhes de qualquer filme, série ou livro, toque no ícone de marcador (🔖) para adicionar à sua lista. Você pode acessar Minha Lista pelo menu do perfil.',
    ),
    _Faq(
      pergunta: 'O que são Addons?',
      resposta: 'Addons são extensões que expandem as funcionalidades do GÊNESIS. Por exemplo: modo cinema, filtros avançados, integração com calendário. Você pode ativar ou desativar cada addon individualmente em Perfil → Addons.',
    ),
    _Faq(
      pergunta: 'Posso ter múltiplos perfis?',
      resposta: 'Sim! O GÊNESIS suporta até 5 perfis por conta. Cada perfil mantém seu próprio histórico, listas e preferências. Gerencie os perfis em Configurações → Gerenciar perfis.',
    ),
    _Faq(
      pergunta: 'Esqueci minha senha, o que faço?',
      resposta: 'Na tela de login, toque em "Esqueci minha senha". Você receberá um e-mail com instruções para criar uma nova senha. Verifique também sua caixa de spam.',
    ),
    _Faq(
      pergunta: 'Como excluir minha conta?',
      resposta: 'Vá em Perfil → Configurações → Conta → Excluir conta. Atenção: essa ação é permanente e removerá todos os seus dados, histórico e downloads.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajuda')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryAccent.withOpacity(0.15), AppColors.surface],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primaryAccent.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                const Icon(Icons.support_agent_outlined, color: AppColors.primaryAccent, size: 40),
                const SizedBox(height: 10),
                const Text(
                  'Como podemos ajudar?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Encontre respostas nas perguntas frequentes\nou entre em contato conosco.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.grey, fontSize: 13, height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          const Text(
            'Perguntas Frequentes',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // FAQs
          ..._faqs.map((faq) => _FaqTile(
                faq: faq,
                onTap: () => setState(() => faq.aberto = !faq.aberto),
              )),

          const SizedBox(height: 24),

          // Contato
          const Text('Ainda precisa de ajuda?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _ContatoTile(
            icon: Icons.email_outlined,
            titulo: 'E-mail',
            subtitulo: 'suporte@genesis.app',
            onTap: () {},
          ),
          _ContatoTile(
            icon: Icons.chat_bubble_outline,
            titulo: 'Chat ao vivo',
            subtitulo: 'Disponível seg–sex, 9h às 18h',
            onTap: () {},
          ),
          _ContatoTile(
            icon: Icons.bug_report_outlined,
            titulo: 'Reportar um problema',
            subtitulo: 'Nos ajude a melhorar o GÊNESIS',
            onTap: () {},
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  final _Faq faq;
  final VoidCallback onTap;

  const _FaqTile({required this.faq, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: faq.aberto
              ? AppColors.primaryAccent.withOpacity(0.4)
              : AppColors.secondary.withOpacity(0.4),
        ),
      ),
      child: Column(
        children: [
          ListTile(
            title: Text(
              faq.pergunta,
              style: TextStyle(
                fontSize: 14,
                fontWeight: faq.aberto ? FontWeight.bold : FontWeight.normal,
                color: faq.aberto ? AppColors.primaryAccent : AppColors.white,
              ),
            ),
            trailing: Icon(
              faq.aberto ? Icons.expand_less : Icons.expand_more,
              color: faq.aberto ? AppColors.primaryAccent : AppColors.grey,
            ),
            onTap: onTap,
          ),
          if (faq.aberto)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                faq.resposta,
                style: const TextStyle(
                  color: AppColors.softAccent,
                  fontSize: 13,
                  height: 1.6,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ContatoTile extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final String subtitulo;
  final VoidCallback onTap;

  const _ContatoTile({
    required this.icon,
    required this.titulo,
    required this.subtitulo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.secondary.withOpacity(0.4)),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primaryAccent, size: 22),
        title: Text(titulo, style: const TextStyle(fontSize: 14)),
        subtitle: Text(subtitulo, style: const TextStyle(color: AppColors.grey, fontSize: 12)),
        trailing: const Icon(Icons.chevron_right, color: AppColors.grey, size: 20),
        onTap: onTap,
      ),
    );
  }
}
