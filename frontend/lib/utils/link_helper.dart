import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LinkHelper {
  /// Tenta abrir o link sempre em uma NOVA ABA do navegador.
  static Future<void> openExternalLink(
      BuildContext context, String? urlString) async {
    if (urlString == null || urlString.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Link indisponível no momento.')),
      );
      return;
    }

    final Uri url = Uri.parse(urlString);

    try {
      // O LaunchMode.externalApplication é a regra de ouro para a Web!
      // Ele impede a "tela branca" e força o navegador a abrir uma nova guia.
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      debugPrint('Erro ao abrir o link: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Não foi possível abrir o link externo.')),
        );
      }
    }
  }
}
