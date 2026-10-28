import '../../recycling/services/user_stats.dart';
import '../models/achievement.dart';

class AchievementService {
  /// Devuelve solo los logros recién cumplidos que aún no estaban desbloqueados.
  static List<Achievement> newlyUnlocked(
          UserStats stats, Set<String> alreadyUnlocked) =>
      allAchievements
          .where((a) => !alreadyUnlocked.contains(a.id) && a.isMet(stats))
          .toList();

  /// Próximo logro por desbloquear (mayor progreso), o null si están todos.
  static Achievement? next(UserStats stats, Set<String> unlocked) {
    final pending =
        allAchievements.where((a) => !unlocked.contains(a.id)).toList();
    if (pending.isEmpty) return null;
    pending.sort((a, b) => b.progress(stats).compareTo(a.progress(stats)));
    return pending.first;
  }
}
