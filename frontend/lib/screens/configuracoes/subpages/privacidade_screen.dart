import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';

class PrivacidadeScreen extends StatelessWidget {
  const PrivacidadeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Política de Privacidade')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          _Header('Política de Privacidade'),
          _SubText('Última atualização: janeiro de 2025'),
          SizedBox(height: 20),

          _Section('1. Informações Coletadas',
              'O GÊNESIS coleta apenas as informações necessárias para o funcionamento do serviço:\n\n• E-mail e nome para criação de conta\n• Histórico de visualização (armazenado localmente no dispositivo)\n• Preferências de perfil\n• Dados de uso anônimos para melhorar o aplicativo\n\nNão coletamos dados de pagamento, localização ou contatos.'),

          _Section('2. Como Usamos Seus Dados',
              'Utilizamos suas informações exclusivamente para:\n\n• Autenticar seu acesso à conta\n• Personalizar sua experiência (recomendações, histórico)\n• Enviar notificações sobre novos conteúdos (se habilitado)\n• Melhorar os algoritmos de recomendação de forma anônima'),

          _Section('3. Armazenamento e Segurança',
              'Seus dados são armazenados com criptografia em servidores seguros. O histórico e listas de favoritos ficam armazenados localmente no seu dispositivo, podendo ser sincronizados com a nuvem mediante sua autorização.\n\nSenhas são armazenadas apenas em formato hash — nunca em texto simples.'),

          _Section('4. Compartilhamento de Dados',
              'NÃO vendemos, alugamos ou compartilhamos seus dados pessoais com terceiros para fins comerciais.\n\nPodemos compartilhar dados anonimizados e agregados com parceiros de análise para melhorar o serviço. Nenhum dado pessoalmente identificável é incluído.'),

          _Section('5. Links para Plataformas Externas',
              'Ao clicar em links para Netflix, Amazon, HBO e outras plataformas, você é redirecionado para sites de terceiros sujeitos às suas próprias políticas de privacidade. Recomendamos lê-las antes de fornecer qualquer informação.'),

          _Section('6. Seus Direitos (LGPD)',
              'Em conformidade com a Lei Geral de Proteção de Dados (LGPD), você tem direito a:\n\n• Acessar todos os dados que temos sobre você\n• Solicitar correção de dados incorretos\n• Solicitar exclusão de sua conta e dados\n• Revogar consentimentos previamente fornecidos\n• Portabilidade dos seus dados\n\nPara exercer esses direitos, entre em contato: privacidade@genesis.app'),

          _Section('7. Cookies e Rastreamento',
              'O aplicativo não utiliza cookies de rastreamento de terceiros. Utilizamos apenas armazenamento local para manter sua sessão e preferências ativas.'),

          _Section('8. Alterações nesta Política',
              'Notificaremos sobre mudanças significativas nesta política com pelo menos 30 dias de antecedência por meio de notificação no aplicativo.'),

          _Section('9. Contato',
              'Dúvidas sobre privacidade:\n\nE-mail: privacidade@genesis.app\nResponsável pelo tratamento de dados: Equipe GÊNESIS'),

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
