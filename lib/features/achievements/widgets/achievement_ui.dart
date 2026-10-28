import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../models/achievement.dart';

IconData achievementIcon(String name) => switch (name) {
      'local_fire_department' => Icons.local_fire_department,
      'checklist' => Icons.checklist,
      'scale' => Icons.scale,
      _ => Icons.eco,
    };

Future<void> showAchievementDialog(
    BuildContext context, List<Achievement> items) {
  return showDialog<void>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(items.length == 1 ? '¡Logro desbloqueado!' : '¡Logros desbloqueados!'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final a in items)
            ListTile(
              leading: Icon(achievementIcon(a.iconName), color: AppColors.orange, size: 32),
              title: Text(a.name),
              subtitle: Text(a.description),
            ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Continuar')),
      ],
    ),
  );
}
