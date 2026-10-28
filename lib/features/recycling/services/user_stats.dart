import '../../../data/models/recycling_activity.dart';
import '../../streak/services/streak_calculator.dart';

class UserStats {
  const UserStats({
    required this.totalKg,
    required this.activityCount,
    required this.currentStreak,
    required this.bestStreak,
    required this.activeDays,
  });
  final double totalKg;
  final int activityCount;
  final int currentStreak;
  final int bestStreak;
  final int activeDays;

  /// Siempre derivadas de los registros persistidos.
  factory UserStats.from(List<RecyclingActivity> activities,
      {required DateTime today}) {
    final s = StreakCalculator.calculate(activities.map((a) => a.date),
        today: today);
    return UserStats(
      totalKg: activities.fold<double>(0, (sum, a) => sum + a.kg),
      activityCount: activities.length,
      currentStreak: s.current,
      bestStreak: s.best,
      activeDays: s.activeDays.length,
    );
  }
}
