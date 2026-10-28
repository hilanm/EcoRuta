import '../models/recycling_activity.dart';

abstract class ActivityRepository {
  Future<void> insert(RecyclingActivity a);
  Future<void> delete(String id);
  Future<List<RecyclingActivity>> all();
  Future<void> clear();
}

abstract class AchievementStore {
  Future<Set<String>> unlockedIds();
  Future<void> unlock(String id, DateTime at);
  Future<void> clear();
}

class InMemoryActivityRepository implements ActivityRepository {
  final _items = <String, RecyclingActivity>{};
  @override
  Future<void> insert(RecyclingActivity a) async => _items[a.id] = a;
  @override
  Future<void> delete(String id) async => _items.remove(id);
  @override
  Future<void> clear() async => _items.clear();
  @override
  Future<List<RecyclingActivity>> all() async => _items.values.toList();
}

class InMemoryAchievementStore implements AchievementStore {
  final _ids = <String>{};
  @override
  Future<Set<String>> unlockedIds() async => {..._ids};
  @override
  Future<void> unlock(String id, DateTime at) async => _ids.add(id);
  @override
  Future<void> clear() async => _ids.clear();
}
