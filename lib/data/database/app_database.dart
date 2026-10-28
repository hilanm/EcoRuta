import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../../core/utils/date_utils.dart';
import '../models/recycling_activity.dart';
import '../models/user_profile.dart';
import '../repositories/activity_repository.dart';
import '../repositories/profile_repository.dart';

class AppDatabase {
  AppDatabase._(this.db);
  final Database db;

  static Future<AppDatabase> open({String? path}) async {
    final file = path ?? p.join(await getDatabasesPath(), 'ecoruta.db');
    final db = await openDatabase(file, version: 1, onCreate: (db, _) async {
      await db.execute('''
        CREATE TABLE activities(
          id TEXT PRIMARY KEY,
          day TEXT NOT NULL,            -- yyyy-MM-dd local
          material TEXT NOT NULL,
          kg REAL NOT NULL CHECK(kg > 0),
          point_id TEXT,
          description TEXT,
          photo_path TEXT)''');
      await db.execute('CREATE INDEX idx_activities_day ON activities(day)');
      await db.execute('''
        CREATE TABLE unlocked_achievements(
          id TEXT PRIMARY KEY,
          unlocked_at TEXT NOT NULL)''');
      await db.execute('''
        CREATE TABLE profile(
          id INTEGER PRIMARY KEY CHECK(id = 1),
          alias TEXT NOT NULL,
          created_day TEXT NOT NULL)''');
    });
    return AppDatabase._(db);
  }

  Future<void> resetAll() async {
    await db.delete('activities');
    await db.delete('unlocked_achievements');
  }
}

class SqliteActivityRepository implements ActivityRepository {
  SqliteActivityRepository(this._db);
  final AppDatabase _db;

  @override
  Future<void> insert(RecyclingActivity a) => _db.db.insert('activities', a.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort);
  @override
  Future<void> delete(String id) =>
      _db.db.delete('activities', where: 'id = ?', whereArgs: [id]);
  @override
  Future<void> clear() => _db.db.delete('activities');
  @override
  Future<List<RecyclingActivity>> all() async =>
      (await _db.db.query('activities', orderBy: 'day DESC'))
          .map(RecyclingActivity.fromMap)
          .toList();
}

class SqliteAchievementStore implements AchievementStore {
  SqliteAchievementStore(this._db);
  final AppDatabase _db;

  @override
  Future<Set<String>> unlockedIds() async =>
      (await _db.db.query('unlocked_achievements'))
          .map((r) => r['id'] as String)
          .toSet();
  @override
  Future<void> unlock(String id, DateTime at) => _db.db.insert(
      'unlocked_achievements', {'id': id, 'unlocked_at': at.toIso8601String()},
      conflictAlgorithm: ConflictAlgorithm.ignore);
  @override
  Future<void> clear() => _db.db.delete('unlocked_achievements');
}

class SqliteProfileRepository implements ProfileRepository {
  SqliteProfileRepository(this._db, {DateTime Function()? clock})
      : _now = clock ?? DateTime.now;
  final AppDatabase _db;
  final DateTime Function() _now;

  @override
  Future<UserProfile> load() async {
    final rows = await _db.db.query('profile', where: 'id = 1');
    if (rows.isEmpty) {
      final p = UserProfile(alias: defaultAlias, createdDay: dayOnly(_now()));
      await _db.db.insert('profile',
          {'id': 1, 'alias': p.alias, 'created_day': dayKey(p.createdDay)});
      return p;
    }
    return UserProfile(
        alias: rows.first['alias'] as String,
        createdDay: parseDayKey(rows.first['created_day'] as String));
  }

  @override
  Future<void> saveAlias(String alias) async {
    await load(); // asegura que exista la fila
    await _db.db.update('profile', {'alias': alias.trim()}, where: 'id = 1');
  }

  @override
  Future<void> reset() => _db.db.delete('profile');
}
