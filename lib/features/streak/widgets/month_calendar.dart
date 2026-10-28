import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_utils.dart';
import '../services/month_grid.dart';

class MonthCalendar extends StatelessWidget {
  const MonthCalendar({
    super.key,
    required this.month,
    required this.activeDays,
    required this.today,
    this.onPrev,
    this.onNext,
  });
  final DateTime month; // cualquier día del mes mostrado
  final Set<DateTime> activeDays; // días UTC (dayOnly)
  final DateTime today;
  final VoidCallback? onPrev, onNext;

  @override
  Widget build(BuildContext context) {
    final t = dayOnly(today);
    final title = DateFormat('MMMM y', 'es').format(DateTime(month.year, month.month));
    final cells = monthGrid(month.year, month.month);
    return Column(children: [
      Row(children: [
        IconButton(
            tooltip: 'Mes anterior',
            onPressed: onPrev,
            icon: const Icon(Icons.chevron_left)),
        Expanded(
          child: Text(title[0].toUpperCase() + title.substring(1),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium),
        ),
        IconButton(
            tooltip: 'Mes siguiente',
            onPressed: onNext,
            icon: const Icon(Icons.chevron_right)),
      ]),
      Row(children: [
        for (final l in const ['L', 'M', 'M', 'J', 'V', 'S', 'D'])
          Expanded(
              child: Center(
                  child: Text(l, style: const TextStyle(color: AppColors.grey, fontSize: 12)))),
      ]),
      const SizedBox(height: Gaps.xs),
      GridView.count(
        crossAxisCount: 7,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          for (final d in cells)
            if (d == null)
              const SizedBox.shrink()
            else
              _Cell(
                day: d,
                active: activeDays.contains(d),
                isToday: d == t,
                future: d.isAfter(t),
              ),
        ],
      ),
    ]);
  }
}

class _Cell extends StatelessWidget {
  const _Cell({required this.day, required this.active, required this.isToday, required this.future});
  final DateTime day;
  final bool active, isToday, future;

  @override
  Widget build(BuildContext context) => Semantics(
        label: '${DateFormat("d 'de' MMMM", 'es').format(day)}, '
            '${active ? "con actividad" : "sin actividad"}${isToday ? ", hoy" : ""}',
        excludeSemantics: true,
        child: Padding(
          padding: const EdgeInsets.all(3),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active ? AppColors.green : null,
              border: isToday ? Border.all(color: AppColors.orange, width: 2) : null,
            ),
            child: Text('${day.day}',
                style: TextStyle(
                  fontWeight: active || isToday ? FontWeight.bold : FontWeight.normal,
                  color: active
                      ? AppColors.white
                      : (future ? AppColors.grey : AppColors.text),
                )),
          ),
        ),
      );
}
