import '../../core/utils/date_utils.dart';
import '../models/user_profile.dart';

abstract class ProfileRepository {
  /// Si no existe perfil lo crea con alias por defecto y la fecha de hoy.
  Future<UserProfile> load();
  Future<void> saveAlias(String alias);
  Future<void> reset();
}

class InMemoryProfileRepository implements ProfileRepository {
  InMemoryProfileRepository({DateTime Function()? clock}) : _now = clock ?? DateTime.now;
  final DateTime Function() _now;
  UserProfile? _p;

  @override
  Future<UserProfile> load() async =>
      _p ??= UserProfile(alias: defaultAlias, createdDay: dayOnly(_now()));
  @override
  Future<void> saveAlias(String alias) async {
    final cur = await load();
    _p = UserProfile(alias: alias.trim(), createdDay: cur.createdDay);
  }

  @override
  Future<void> reset() async => _p = null;
}
