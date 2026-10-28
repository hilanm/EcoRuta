import '../../../core/utils/date_utils.dart';
import '../../../data/models/recycling_activity.dart';

/// Días activos de la semana actual (lunes a domingo, fechas locales).
class WeekSummary {
  WeekSummary(this.days, this.active, this.todayIndex);
  final List<DateTime> days;
  final List<bool> active;
  final int todayIndex;
  int get activeCount => active.where((a) => a).length;

  static WeekSummary of(Iterable<RecyclingActivity> activities, DateTime today) {
    final t = dayOnly(today);
    final monday = t.subtract(Duration(days: t.weekday - 1));
    final days = [for (var i = 0; i < 7; i++) monday.add(Duration(days: i))];
    final set = activities.map((a) => dayOnly(a.date)).toSet();
    return WeekSummary(days, [for (final d in days) set.contains(d)], t.weekday - 1);
  }
}
