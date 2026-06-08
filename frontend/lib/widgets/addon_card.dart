import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import '../models/addon.dart';

class AddonCard extends StatelessWidget {
  final Addon addon;
  final ValueChanged<bool> onToggle;

  const AddonCard({
    super.key,
    required this.addon,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    addon.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Chip(label: Text(addon.category)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              addon.description,
              style: const TextStyle(color: AppColors.grey, fontSize: 13),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Chip(
                  avatar: const Icon(Icons.person, size: 14, color: AppColors.softAccent),
                  label: Text(addon.author),
                ),
                Switch(
                  value: addon.enabled,
                  onChanged: onToggle,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
