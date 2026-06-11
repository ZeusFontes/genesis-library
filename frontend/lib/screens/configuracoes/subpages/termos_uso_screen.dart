import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';

class TermosUsoScreen extends StatelessWidget {
  const TermosUsoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Termos de Uso')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          _Header('Termos de Uso do GÊNESIS'),
          _SubText('Última atualização: janeiro de 2025'),
          SizedBox(height: 20),

          _Section('1. Aceitação dos Termos',
              'Ao acessar e utilizar o aplicativo GÊNESIS, você concorda com estes Termos de Uso. Caso não concorde com alguma condição, não utilize o serviço.\n\nO GÊNESIS se reserva o direito de modificar estes termos a qualquer momento, com aviso prévio ao usuário via notificação no aplicativo.'),

          _Section('2. Descrição do Serviço',
              'O GÊNESIS é uma plataforma de streaming e biblioteca de mídia que oferece:\n\n• Acesso a filmes, séries e livros de domínio público gratuitamente\n• Links para plataformas externas de streaming (Netflix, Prime Video, etc.)\n• Funcionalidades de organização de listas e histórico\n• Sistema de perfis para múltiplos usuários\n\nO aplicativo NÃO hospeda conteúdo protegido por direitos autorais.'),

          _Section('3. Conta de Usuário',
              'Você é responsável por manter a confidencialidade de sua senha e por todas as atividades realizadas em sua conta. Notifique-nos imediatamente sobre qualquer uso não autorizado.\n\nUma conta pode ter até 5 perfis distintos. Cada perfil mantém seu próprio histórico e lista de favoritos.'),

          _Section('4. Uso Aceitável',
              'Você concorda em NÃO:\n\n• Usar o serviço para fins ilegais\n• Tentar acessar dados de outros usuários\n• Realizar engenharia reversa do aplicativo\n• Reproduzir ou distribuir conteúdo protegido por direitos autorais\n• Compartilhar credenciais de acesso com terceiros não autorizados'),

          _Section('5. Conteúdo de Domínio Público',
              'O conteúdo marcado como "Domínio Público" é de livre acesso e reprodução conforme as leis vigentes. O GÊNESIS não garante a completude ou qualidade deste conteúdo, pois pode variar conforme legislação de cada país.'),

          _Section('6. Links Externos',
              'O GÊNESIS redireciona para plataformas de terceiros (Netflix, Amazon, HBO etc.) para conteúdos não-públicos. Não nos responsabilizamos pelos termos, preços ou disponibilidade destas plataformas externas.'),

          _Section('7. Limitação de Responsabilidade',
              'O GÊNESIS é fornecido "como está", sem garantias expressas ou implícitas de disponibilidade contínua do serviço. Não nos responsabilizamos por danos decorrentes da interrupção do serviço.'),

          _Section('8. Contato',
              'Para dúvidas sobre estes Termos de Uso, entre em contato pelo e-mail: suporte@genesis.app'),

          SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String text;
  const _Header(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold));
  }
}

class _SubText extends StatelessWidget {
  final String text;
  const _SubText(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(text, style: const TextStyle(color: AppColors.grey, fontSize: 12)),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String body;
  const _Section(this.title, this.body);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primaryAccent)),
          const SizedBox(height: 8),
          Text(body, style: const TextStyle(color: AppColors.softAccent, fontSize: 13, height: 1.7)),
        ],
      ),
    );
  }
}
