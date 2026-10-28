import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../streak/services/streak_messages.dart';
import '../../streak/widgets/animated_flame.dart';

class StreakCard extends StatelessWidget {
  const StreakCard({super.key, required this.current, required this.best, required this.activeToday});
  final int current, best;
  final bool activeToday;

  @override
  Widget build(BuildContext context) => Semantics(
        label: 'Racha actual: $current ${current == 1 ? "día" : "días"}. Récord: $best.',
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(Gaps.l),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [AppColors.darkGreen, AppColors.green],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(Gaps.radius),
            boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 12, offset: Offset(0, 4))],
          ),
          child: Row(children: [
            AnimatedFlame(streak: current),
            const SizedBox(width: Gaps.m),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('$current ${current == 1 ? "día" : "días"}',
                    style: const TextStyle(color: AppColors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                Text('de racha · Récord: $best',
                    style: const TextStyle(color: AppColors.lightGreen)),
                const SizedBox(height: Gaps.xs),
                Text(motivationalMessage(current: current, best: best, activeToday: activeToday),
                    style: const TextStyle(color: AppColors.white)),
              ]),
            ),
          ]),
        ),
      );
}
