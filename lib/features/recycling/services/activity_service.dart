import '../../../core/utils/date_utils.dart';
import '../../../data/models/recycling_activity.dart';
import '../../../data/models/recycling_material.dart';
import '../../../data/repositories/activity_repository.dart';
import '../../achievements/models/achievement.dart';
import '../../achievements/services/achievement_service.dart';
import 'user_stats.dart';

class ValidationException implements Exception {
  ValidationException(this.message);
  final String message;
  @override
  String toString() => message;
}

class RegisterResult {
  RegisterResult(this.activity, this.stats, this.newAchievements);
  final RecyclingActivity activity;
  final UserStats stats;
  final List<Achievement> newAchievements;
}

class ActivityService {
  ActivityService(this._repo, this._store, {DateTime Function()? clock})
      : _now = clock ?? DateTime.now;
  final ActivityRepository _repo;
  final AchievementStore _store;
  final DateTime Function() _now; // inyectable para pruebas
  int _seq = 0;

  static String? validate(
      {required double? kg, required RecyclingMaterial? material,
      required DateTime? date, required DateTime today}) {
    if (material == null) return 'Selecciona un material.';
    if (kg == null || kg.isNaN || kg.isInfinite) return 'Ingresa una cantidad válida.';
    if (kg <= 0) return 'La cantidad debe ser mayor que cero.';
    if (date == null) return 'Selecciona una fecha.';
    if (daysBetween(today, date) > 0) return 'La fecha no puede ser futura.';
    return null;
  }

  Future<RegisterResult> register({
    required RecyclingMaterial? material,
    required double? kg,
    required DateTime? date,
    String? pointId,
    String? description,
    String? photoPath,
  }) async {
    final now = _now();
    final error = validate(kg: kg, material: material, date: date, today: now);
    if (error != null) throw ValidationException(error); // no se guarda nada
    final activity = RecyclingActivity(
      id: '${now.microsecondsSinceEpoch}-${_seq++}',
      date: date!,
      material: material!,
      kg: kg!,
      pointId: pointId,
      description: description,
      photoPath: photoPath,
    );
    await _repo.insert(activity);
    final stats = await currentStats();
    final unlocked = await _store.unlockedIds();
    final fresh = AchievementService.newlyUnlocked(stats, unlocked);
    for (final a in fresh) {
      await _store.unlock(a.id, now);
    }
    return RegisterResult(activity, stats, fresh);
  }

  Future<void> remove(String id) => _repo.delete(id);

  Future<UserStats> currentStats() async =>
      UserStats.from(await _repo.all(), today: _now());
}
