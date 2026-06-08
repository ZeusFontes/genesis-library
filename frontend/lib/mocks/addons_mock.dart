import '../models/addon.dart';

class AddonsMock {
  static final List<Addon> addons = [
    Addon(
      id: 'a1',
      name: 'IMDB Ratings',
      description: 'Exibe notas do IMDB em todos os cards de mídia.',
      author: 'GÊNESIS Team',
      category: 'Info',
      enabled: true,
    ),
    Addon(
      id: 'a2',
      name: 'Rotten Tomatoes',
      description: 'Exibe a pontuação do Rotten Tomatoes nos detalhes.',
      author: 'GÊNESIS Team',
      category: 'Info',
      enabled: true,
    ),
    Addon(
      id: 'a3',
      name: 'Subtitles Pro',
      description: 'Adiciona legendas automáticas para conteúdo de domínio público.',
      author: 'SubLabs',
      category: 'Player',
      enabled: false,
    ),
    Addon(
      id: 'a4',
      name: 'Night Mode Reader',
      description: 'Modo noturno otimizado para leitura de livros.',
      author: 'ReadBetter',
      category: 'Leitura',
      enabled: true,
    ),
    Addon(
      id: 'a5',
      name: 'Download Manager',
      description: 'Gerencia downloads de conteúdo de domínio público.',
      author: 'DLPro',
      category: 'Download',
      enabled: false,
    ),
  ];
}
