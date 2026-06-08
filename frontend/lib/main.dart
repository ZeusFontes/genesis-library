import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/routes.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/cadastro_screen.dart';
import 'screens/auth/esqueci_senha_screen.dart';
import 'screens/profiles/profile_selection_screen.dart';
import 'screens/details/movie_detail_screen.dart';
import 'screens/details/book_detail_screen.dart';
import 'screens/downloads/downloads_screen.dart';
import 'screens/historico/historico_screen.dart';
import 'screens/notificacoes/notificacoes_screen.dart';
import 'screens/configuracoes/configuracoes_screen.dart';
import 'screens/configuracoes/subpages/alterar_senha_screen.dart';
import 'screens/configuracoes/subpages/gerenciar_perfis_screen.dart';
import 'screens/configuracoes/subpages/termos_uso_screen.dart';
import 'screens/configuracoes/subpages/privacidade_screen.dart';
import 'screens/configuracoes/subpages/sobre_screen.dart';
import 'screens/configuracoes/subpages/ajuda_screen.dart';
import 'screens/busca/busca_screen.dart';
import 'navigation/main_navigation_screen.dart';

void main() {
  runApp(const GenesisApp());
}

class GenesisApp extends StatelessWidget {
  const GenesisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GÊNESIS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: AppRoutes.login,
      routes: {
        AppRoutes.login: (_) => const LoginScreen(),
        AppRoutes.cadastro: (_) => const CadastroScreen(),
        AppRoutes.esqueciSenha: (_) => const EsqueciSenhaScreen(),
        AppRoutes.profiles: (_) => const ProfileSelectionScreen(),
        AppRoutes.home: (_) => const MainNavigationScreen(),
        AppRoutes.movieDetail: (_) => const MovieDetailScreen(),
        AppRoutes.bookDetail: (_) => const BookDetailScreen(),
        AppRoutes.downloads: (_) => const DownloadsScreen(),
        AppRoutes.historico: (_) => const HistoricoScreen(),
        AppRoutes.notificacoes: (_) => const NotificacoesScreen(),
        AppRoutes.configuracoes: (_) => const ConfiguracoesScreen(),
        AppRoutes.busca: (_) => const BuscaScreen(),
        AppRoutes.alterarSenha: (_) => const AlterarSenhaScreen(),
        AppRoutes.gerenciarPerfis: (_) => const GerenciarPerfisScreen(),
        AppRoutes.termos: (_) => const TermosUsoScreen(),
        AppRoutes.privacidade: (_) => const PrivacidadeScreen(),
        AppRoutes.sobre: (_) => const SobreScreen(),
        AppRoutes.ajuda: (_) => const AjudaScreen(),
      },
    );
  }
}
