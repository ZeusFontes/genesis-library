import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

class HistoricoScreen extends StatelessWidget {
  const HistoricoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Histórico')),
      body: const _EmptyHistory(),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.secondary),
            ),
            child: const Icon(Icons.history, size: 48, color: AppColors.softAccent),
          ),
          const SizedBox(height: 24),
          const Text(
            'Histórico vazio',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'O que você assistir e ler aparecerá aqui para você continuar depois.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.grey, fontSize: 14, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
