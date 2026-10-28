import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../services/week_summary.dart';

class WeekDots extends StatelessWidget {
  const WeekDots({super.key, required this.week});
  final WeekSummary week;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (var i = 0; i < 7; i++)
            Semantics(
              label: '${week.active[i] ? "Día activo" : "Sin actividad"}'
                  '${i == week.todayIndex ? ", hoy" : ""}',
              child: Column(children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: week.active[i] ? AppColors.green : AppColors.background,
                    border: i == week.todayIndex
                        ? Border.all(color: AppColors.orange, width: 2)
                        : null,
                  ),
                  child: week.active[i]
                      ? const Icon(Icons.check, size: 18, color: AppColors.white)
                      : null,
                ),
                const SizedBox(height: Gaps.xs),
                Text('LMMJVSD'[i],
                    style: TextStyle(
                        fontSize: 12,
                        color: i > week.todayIndex ? AppColors.grey : AppColors.text)),
              ]),
            ),
        ],
      );
}
