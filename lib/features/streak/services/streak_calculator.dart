import '../../../core/utils/date_utils.dart';

class StreakRun {
  const StreakRun(this.start, this.end);
  final DateTime start;
  final DateTime end;
  int get length => daysBetween(start, end) + 1;
}

class StreakResult {
  const StreakResult({
    required this.current,
    required this.best,
    required this.activeDays,
    required this.pastRuns,
  });
  final int current;
  final int best;
  final List<DateTime> activeDays; // ordenados, únicos, <= hoy
  final List<StreakRun> pastRuns; // rachas terminadas (no la actual)
}

/// Cálculo puro de rachas a partir de las fechas de TODAS las actividades.
///
/// Reglas:
/// - Varias actividades el mismo día = 1 día.
/// - La racha actual está viva si hubo actividad hoy, o ayer (el usuario aún
///   puede registrar hoy). Si el último día activo es anterior a ayer, es 0.
/// - Fechas futuras se ignoran.
/// - Actividades retroactivas cuentan en la fecha elegida.
/// - El récord es la mayor racha histórica, aunque ya se haya interrumpido.
class StreakCalculator {
  static StreakResult calculate(Iterable<DateTime> dates,
      {required DateTime today}) {
    final t = dayOnly(today);
    final days = dates.map(dayOnly).where((d) => !d.isAfter(t)).toSet().toList()
      ..sort();

    final runs = <StreakRun>[];
    if (days.isNotEmpty) {
      var start = days.first;
      var prev = days.first;
      for (final d in days.skip(1)) {
        if (daysBetween(prev, d) == 1) {
          prev = d;
        } else {
          runs.add(StreakRun(start, prev));
          start = d;
          prev = d;
        }
      }
      runs.add(StreakRun(start, prev));
    }

    var current = 0;
    var past = List<StreakRun>.of(runs);
    if (runs.isNotEmpty && daysBetween(runs.last.end, t) <= 1) {
      current = runs.last.length;
      past = runs.sublist(0, runs.length - 1);
    }
    final best = runs.fold<int>(0, (m, r) => r.length > m ? r.length : m);
    return StreakResult(
        current: current, best: best, activeDays: days, pastRuns: past);
  }
}
