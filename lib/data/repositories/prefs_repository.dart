import 'package:shared_preferences/shared_preferences.dart';

/// Solo preferencias sencillas de la app.
abstract class PrefsRepository {
  Future<bool> showAchievementPopups();
  Future<void> setShowAchievementPopups(bool value);
}

class SharedPrefsRepository implements PrefsRepository {
  static const _key = 'show_achievement_popups';
  @override
  Future<bool> showAchievementPopups() async =>
      (await SharedPreferences.getInstance()).getBool(_key) ?? true;
  @override
  Future<void> setShowAchievementPopups(bool value) async =>
      (await SharedPreferences.getInstance()).setBool(_key, value);
}

class InMemoryPrefsRepository implements PrefsRepository {
  bool _v = true;
  @override
  Future<bool> showAchievementPopups() async => _v;
  @override
  Future<void> setShowAchievementPopups(bool value) async => _v = value;
}
