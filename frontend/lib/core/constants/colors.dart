import 'package:flutter/material.dart';

class AppColors {
  // Fundo principal (Netflix usa preto absoluto para economizar bateria em telas OLED e dar imersão)
  static const background = Color(0xFF000000);

  // Superfícies como a Bottom Navigation Bar e fundos com leve elevação
  static const surface = Color(0xFF121212);

  // Elementos secundários como os botões de filtro no topo ("Séries", "Filmes", "Jogos")
  static const secondary = Color(0xFF333333);

  // Textos inativos, bordas sutis e ícones não selecionados
  static const softAccent = Color(0xFFB3B3B3);

  // O Vermelho clássico da Netflix para botões principais, logo e seleções ativas
  static const primaryAccent = Color.fromARGB(255, 217, 173, 0);

  static const white = Colors.white;

  // Cinza médio para descrições ("Sinistro • Nostálgico • Ficção científica")
  static const grey = Color(0xFF808080);
}
