import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../recycling/services/user_stats.dart';
import '../models/achievement.dart';
import 'achievement_ui.dart';

class AchievementTile extends StatelessWidget {
  const AchievementTile({super.key, required this.achievement, required this.stats, required this.unlocked});
  final Achievement achievement;
  final UserStats stats;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('0.##', 'es');
    final value = achievement.metric(stats);
    final shown = value > achievement.target ? achievement.target : value;
    return Semantics(
      label: '${achievement.name}, ${unlocked ? "desbloqueado" : "bloqueado"}. ${achievement.description}',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Gaps.xs),
        child: Row(children: [
          Icon(achievementIcon(achievement.iconName),
              size: 30, color: unlocked ? AppColors.orange : AppColors.grey),
          const SizedBox(width: Gaps.m),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(achievement.name,
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: unlocked ? AppColors.text : AppColors.grey)),
              Text(achievement.description,
                  style: const TextStyle(fontSize: 12, color: AppColors.grey)),
              if (!unlocked) ...[
                const SizedBox(height: Gaps.xs),
                LinearProgressIndicator(
                  value: achievement.progress(stats),
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(6),
                  color: AppColors.orange,
                  backgroundColor: AppColors.background,
                ),
                Text('${fmt.format(shown)} / ${fmt.format(achievement.target)}',
                    style: const TextStyle(fontSize: 11, color: AppColors.grey)),
              ],
            ]),
          ),
          if (unlocked) const Icon(Icons.check_circle, color: AppColors.green),
        ]),
      ),
    );
  }
}
