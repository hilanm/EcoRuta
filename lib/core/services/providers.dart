import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database/app_database.dart';
import '../../data/models/recycling_activity.dart';
import '../../data/models/user_profile.dart';
import '../../data/repositories/prefs_repository.dart';
import '../../data/repositories/profile_repository.dart';
import '../../data/repositories/activity_repository.dart';
import '../../features/recycling/services/activity_service.dart';

/// Se sobreescribe en main.dart con la base ya abierta.
final databaseProvider =
    Provider<AppDatabase>((ref) => throw UnimplementedError());

final activityRepositoryProvider = Provider<ActivityRepository>(
    (ref) => SqliteActivityRepository(ref.watch(databaseProvider)));

final achievementStoreProvider = Provider<AchievementStore>(
    (ref) => SqliteAchievementStore(ref.watch(databaseProvider)));

final activityServiceProvider = Provider<ActivityService>((ref) =>
    ActivityService(ref.watch(activityRepositoryProvider),
        ref.watch(achievementStoreProvider)));

final activitiesProvider = FutureProvider<List<RecyclingActivity>>(
    (ref) => ref.watch(activityRepositoryProvider).all());

final unlockedIdsProvider = FutureProvider<Set<String>>(
    (ref) => ref.watch(achievementStoreProvider).unlockedIds());

/// Pestaña activa de la barra inferior.
final tabIndexProvider = StateProvider<int>((ref) => 0);

final profileRepositoryProvider = Provider<ProfileRepository>(
    (ref) => SqliteProfileRepository(ref.watch(databaseProvider)));

final profileProvider = FutureProvider<UserProfile>((ref) async =>
    ref.watch(profileRepositoryProvider).load());

final prefsRepositoryProvider =
    Provider<PrefsRepository>((ref) => SharedPrefsRepository());

final showAchievementPopupsProvider = FutureProvider<bool>((ref) async =>
    ref.watch(prefsRepositoryProvider).showAchievementPopups());
