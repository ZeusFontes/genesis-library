import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/routes.dart';

class ConfiguracoesScreen extends StatefulWidget {
  const ConfiguracoesScreen({super.key});

  @override
  State<ConfiguracoesScreen> createState() => _ConfiguracoesScreenState();
}

class _ConfiguracoesScreenState extends State<ConfiguracoesScreen> {
  bool _autoplay = true;
  bool _notificacoes = true;
  bool _modoOffline = false;
  bool _autoDownload = false;
  String _qualidadeVideo = 'Alta';
  String _qualidadeDownload = 'Média';
  String _idioma = 'Português (BR)';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: ListView(
        children: [
          _SectionHeader('Reprodução'),
          _SwitchTile(
            icon: Icons.play_circle_outline,
            title: 'Reprodução automática',
            subtitle: 'Iniciar próximo episódio automaticamente',
            value: _autoplay,
            onChanged: (v) => setState(() => _autoplay = v),
          ),
          _DropdownTile(
            icon: Icons.hd_outlined,
            title: 'Qualidade do vídeo',
            value: _qualidadeVideo,
            options: const ['Automática', 'Baixa', 'Média', 'Alta', '4K'],
            onChanged: (v) => setState(() => _qualidadeVideo = v!),
          ),

          _SectionHeader('Downloads'),
          _SwitchTile(
            icon: Icons.download_outlined,
            title: 'Download automático',
            subtitle: 'Baixar conteúdo de domínio público ao conectar ao Wi-Fi',
            value: _autoDownload,
            onChanged: (v) => setState(() => _autoDownload = v),
          ),
          _DropdownTile(
            icon: Icons.high_quality_outlined,
            title: 'Qualidade dos downloads',
            value: _qualidadeDownload,
            options: const ['Baixa', 'Média', 'Alta'],
            onChanged: (v) => setState(() => _qualidadeDownload = v!),
          ),
          _SwitchTile(
            icon: Icons.wifi_off_outlined,
            title: 'Modo offline',
            subtitle: 'Usar apenas conteúdo baixado',
            value: _modoOffline,
            onChanged: (v) => setState(() => _modoOffline = v),
          ),

          _SectionHeader('Notificações'),
          _SwitchTile(
            icon: Icons.notifications_outlined,
            title: 'Notificações',
            subtitle: 'Avisos de novos conteúdos e atualizações',
            value: _notificacoes,
            onChanged: (v) => setState(() => _notificacoes = v),
          ),

          _SectionHeader('Aparência e Idioma'),
          _DropdownTile(
            icon: Icons.language_outlined,
            title: 'Idioma do app',
            value: _idioma,
            options: const ['Português (BR)', 'English', 'Español'],
            onChanged: (v) => setState(() => _idioma = v!),
          ),

          _SectionHeader('Conta'),
          _ActionTile(
            icon: Icons.lock_outline,
            title: 'Alterar senha',
            onTap: () => Navigator.pushNamed(context, AppRoutes.alterarSenha),
          ),
          _ActionTile(
            icon: Icons.manage_accounts_outlined,
            title: 'Gerenciar perfis',
            onTap: () => Navigator.pushNamed(context, AppRoutes.gerenciarPerfis),
          ),
          _ActionTile(
            icon: Icons.delete_outline,
            title: 'Excluir conta',
            textColor: Colors.redAccent,
            iconColor: Colors.redAccent,
            onTap: () => _showDeleteAccountDialog(context),
          ),

          _SectionHeader('Suporte'),
          _ActionTile(
            icon: Icons.help_outline,
            title: 'Ajuda e FAQ',
            onTap: () => Navigator.pushNamed(context, AppRoutes.ajuda),
          ),

          _SectionHeader('Sobre'),
          _InfoTile(icon: Icons.info_outline, title: 'Versão do app', trailing: '1.0.0'),
          _ActionTile(
            icon: Icons.description_outlined,
            title: 'Termos de uso',
            onTap: () => Navigator.pushNamed(context, AppRoutes.termos),
          ),
          _ActionTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Política de privacidade',
            onTap: () => Navigator.pushNamed(context, AppRoutes.privacidade),
          ),
          _ActionTile(
            icon: Icons.star_outline,
            title: 'Sobre o GÊNESIS',
            onTap: () => Navigator.pushNamed(context, AppRoutes.sobre),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Excluir conta?'),
        content: const Text(
          'Esta ação é irreversível. Todos os seus dados, histórico e downloads serão removidos permanentemente.',
          style: TextStyle(color: AppColors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.softAccent)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Excluir', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryAccent,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.secondary.withOpacity(0.4)),
      ),
      child: SwitchListTile(
        secondary: Icon(icon, color: AppColors.softAccent, size: 22),
        title: Text(title, style: const TextStyle(fontSize: 14)),
        subtitle: subtitle != null
            ? Text(subtitle!, style: const TextStyle(color: AppColors.grey, fontSize: 12))
            : null,
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}

class _DropdownTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final List<String> options;
  final ValueChanged<String?> onChanged;

  const _DropdownTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.secondary.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.softAccent, size: 22),
          const SizedBox(width: 16),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 14))),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              dropdownColor: AppColors.surface,
              style: const TextStyle(color: AppColors.softAccent, fontSize: 13),
              items: options.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? textColor;
  final Color? iconColor;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.textColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.secondary.withOpacity(0.4)),
      ),
      child: ListTile(
        leading: Icon(icon, color: iconColor ?? AppColors.softAccent, size: 22),
        title: Text(title, style: TextStyle(fontSize: 14, color: textColor)),
        trailing: const Icon(Icons.chevron_right, color: AppColors.grey, size: 20),
        onTap: onTap,
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String trailing;

  const _InfoTile({required this.icon, required this.title, required this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.secondary.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.softAccent, size: 22),
          const SizedBox(width: 16),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 14))),
          Text(trailing, style: const TextStyle(color: AppColors.grey, fontSize: 13)),
        ],
      ),
    );
  }
}
