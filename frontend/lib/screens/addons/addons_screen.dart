import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../mocks/addons_mock.dart';
import '../../models/addon.dart';
import '../../widgets/addon_card.dart';

class AddonsScreen extends StatefulWidget {
  const AddonsScreen({super.key});

  @override
  State<AddonsScreen> createState() => _AddonsScreenState();
}

class _AddonsScreenState extends State<AddonsScreen> {
  late List<Addon> _addons;

  @override
  void initState() {
    super.initState();
    _addons = List.from(AddonsMock.addons);
  }

  void _toggle(String id, bool value) {
    setState(() {
      final index = _addons.indexWhere((a) => a.id == id);
      if (index != -1) _addons[index].enabled = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Addons'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: AppColors.softAccent),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  backgroundColor: AppColors.surface,
                  title: const Text('Sobre Addons'),
                  content: const Text(
                    'Addons expandem as funcionalidades do GÊNESIS. Ative ou desative conforme sua preferência.',
                    style: TextStyle(color: AppColors.grey),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK', style: TextStyle(color: AppColors.primaryAccent)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Expanda as funcionalidades do GÊNESIS',
            style: TextStyle(color: AppColors.grey, fontSize: 13),
          ),
          const SizedBox(height: 16),
          ..._addons.map((addon) => AddonCard(
                addon: addon,
                onToggle: (val) => _toggle(addon.id, val),
              )),
        ],
      ),
    );
  }
}
