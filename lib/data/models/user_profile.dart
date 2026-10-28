const defaultAlias = 'Reciclador';

class UserProfile {
  const UserProfile({required this.alias, required this.createdDay});
  final String alias;
  final DateTime createdDay; // día local (UTC medianoche), solo fecha
}
