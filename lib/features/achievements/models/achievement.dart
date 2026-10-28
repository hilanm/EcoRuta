import '../../recycling/services/user_stats.dart';

class Achievement {
  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.iconName,
    required this.target,
    required this.metric,
  });
  final String id;
  final String name;
  final String description;
  final String iconName; // la UI lo traduce a IconData
  final double target;
  final double Function(UserStats) metric;

  /// Condición de desbloqueo: métrica alcanza el objetivo.
  bool isMet(UserStats s) => metric(s) >= target;
  double progress(UserStats s) => (metric(s) / target).clamp(0.0, 1.0);
}

double _best(UserStats s) => s.bestStreak.toDouble();
double _count(UserStats s) => s.activityCount.toDouble();
double _kg(UserStats s) => s.totalKg;

/// Los logros de racha usan el récord histórico: una vez alcanzados no se
/// pierden aunque la racha actual se interrumpa.
final List<Achievement> allAchievements = [
  const Achievement(id: 'first', name: 'Primer reciclaje', description: 'Registra tu primera actividad.', iconName: 'eco', target: 1, metric: _count),
  const Achievement(id: 'streak3', name: 'Tres días seguidos', description: 'Alcanza una racha de 3 días.', iconName: 'local_fire_department', target: 3, metric: _best),
  const Achievement(id: 'streak7', name: 'Una semana', description: 'Alcanza una racha de 7 días.', iconName: 'local_fire_department', target: 7, metric: _best),
  const Achievement(id: 'streak14', name: 'Dos semanas', description: 'Alcanza una racha de 14 días.', iconName: 'local_fire_department', target: 14, metric: _best),
  const Achievement(id: 'streak30', name: 'Un mes', description: 'Alcanza una racha de 30 días.', iconName: 'local_fire_department', target: 30, metric: _best),
  const Achievement(id: 'act10', name: 'Diez actividades', description: 'Registra 10 actividades.', iconName: 'checklist', target: 10, metric: _count),
  const Achievement(id: 'kg5', name: '5 kg reciclados', description: 'Declara 5 kg en total.', iconName: 'scale', target: 5, metric: _kg),
  const Achievement(id: 'kg25', name: '25 kg reciclados', description: 'Declara 25 kg en total.', iconName: 'scale', target: 25, metric: _kg),
];
