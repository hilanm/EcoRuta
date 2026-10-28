import 'package:ecoruta/data/models/recycling_material.dart';
import 'package:ecoruta/data/repositories/activity_repository.dart';
import 'package:ecoruta/features/recycling/services/activity_service.dart';
import 'package:ecoruta/features/streak/services/streak_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

StreakResult calc(List<DateTime> d, DateTime today) =>
    StreakCalculator.calculate(d, today: today);

ActivityService makeService(DateTime Function() clock,
        [InMemoryActivityRepository? repo, InMemoryAchievementStore? store]) =>
    ActivityService(repo ?? InMemoryActivityRepository(),
        store ?? InMemoryAchievementStore(),
        clock: clock);

void main() {
  final today = DateTime(2026, 5, 10, 15, 30);
  DateTime d(int day, [int h = 12]) => DateTime(2026, 5, day, h);

  group('Rachas', () {
    test('1. sin actividades la racha es 0', () {
      final r = calc([], today);
      expect(r.current, 0);
      expect(r.best, 0);
    });

    test('2. una actividad hoy = racha de 1', () {
      expect(calc([d(10)], today).current, 1);
    });

    test('3. dos días consecutivos = 2', () {
      expect(calc([d(9), d(10)], today).current, 2);
    });

    test('4. varias actividades el mismo día cuentan una vez', () {
      final r = calc([d(10, 8), d(10, 12), d(10, 23)], today);
      expect(r.current, 1);
      expect(r.activeDays.length, 1);
    });

    test('5. un día intermedio sin actividad interrumpe la racha', () {
      final r = calc([d(7), d(8), d(10)], today);
      expect(r.current, 1);
    });

    test('la racha sigue viva si la última actividad fue ayer', () {
      expect(calc([d(8), d(9)], today).current, 2);
    });

    test('la racha se rompe si el último día activo fue anteayer', () {
      expect(calc([d(7), d(8)], today).current, 0);
    });

    test('6. racha anterior se conserva como récord', () {
      final r = calc([d(1), d(2), d(3), d(4), d(8), d(9)], today);
      expect(r.best, 4);
      expect(r.current, 2);
      expect(r.pastRuns.length, 1);
      expect(r.pastRuns.first.length, 4);
    });

    test('7. actividad retroactiva une rachas según su fecha', () {
      final antes = calc([d(8), d(10)], today);
      expect(antes.current, 1);
      final despues = calc([d(8), d(9), d(10)], today); // se añade el 9
      expect(despues.current, 3);
    });

    test('7b. retroactiva no cuenta como hoy', () {
      final r = calc([d(3)], today);
      expect(r.current, 0);
      expect(r.best, 1);
    });

    test('fechas futuras se ignoran', () {
      expect(calc([d(11), d(12)], today).current, 0);
    });

    test('8. horas límite del día y cambio de horario (DST) no distorsionan', () {
      // 23:59 y 00:01 siguientes son días distintos.
      final r = calc([DateTime(2026, 5, 9, 23, 59), DateTime(2026, 5, 10, 0, 1)], today);
      expect(r.current, 2);
      // 00:00 y 23:59 del mismo día cuentan una vez.
      expect(calc([DateTime(2026, 5, 10, 0, 0), DateTime(2026, 5, 10, 23, 59)], today).current, 1);
      // Cruce de fin de mes y de año.
      final eoy = calc([DateTime(2025, 12, 31, 23), DateTime(2026, 1, 1, 1)],
          DateTime(2026, 1, 1, 10));
      expect(eoy.current, 2);
      // Días consecutivos a través de un cambio de hora (Chile, abril/sept).
      final dst = calc(
          [for (var i = 3; i <= 8; i++) DateTime(2026, 4, i, 12)],
          DateTime(2026, 4, 8, 20));
      expect(dst.current, 6);
      final dst2 = calc(
          [for (var i = 4; i <= 9; i++) DateTime(2026, 9, i, 12)],
          DateTime(2026, 9, 9, 20));
      expect(dst2.current, 6);
    });
  });

  group('Registro, estadísticas y logros', () {
    test('9. cantidad inválida no se guarda ni altera estadísticas', () async {
      final repo = InMemoryActivityRepository();
      final s = makeService(() => today, repo);
      for (final kg in [0.0, -1.0, double.nan, null]) {
        expect(
          () => s.register(material: RecyclingMaterial.glass, kg: kg, date: today),
          throwsA(isA<ValidationException>()),
        );
      }
      expect(() => s.register(material: null, kg: 1, date: today),
          throwsA(isA<ValidationException>()));
      expect(() => s.register(material: RecyclingMaterial.glass, kg: 1, date: DateTime(2026, 5, 11)),
          throwsA(isA<ValidationException>()));
      expect((await repo.all()), isEmpty);
      final st = await s.currentStats();
      expect(st.currentStreak, 0);
      expect(st.totalKg, 0);
    });

    test('10. estadísticas se actualizan al agregar y eliminar', () async {
      final s = makeService(() => today);
      final r1 = await s.register(material: RecyclingMaterial.plastic, kg: 1.5, date: today);
      expect(r1.stats.totalKg, 1.5);
      expect(r1.stats.activityCount, 1);
      expect(r1.stats.currentStreak, 1);
      final r2 = await s.register(
          material: RecyclingMaterial.glass, kg: 2, date: DateTime(2026, 5, 9));
      expect(r2.stats.totalKg, 3.5);
      expect(r2.stats.currentStreak, 2);
      await s.remove(r2.activity.id);
      final after = await s.currentStats();
      expect(after.totalKg, 1.5);
      expect(after.activityCount, 1);
      expect(after.currentStreak, 1);
    });

    test('11. logros se desbloquean al cumplir condición y no se duplican', () async {
      final store = InMemoryAchievementStore();
      final s = makeService(() => today, InMemoryActivityRepository(), store);
      final r1 = await s.register(material: RecyclingMaterial.paper, kg: 1, date: DateTime(2026, 5, 8));
      expect(r1.newAchievements.map((a) => a.id), ['first']);
      await s.register(material: RecyclingMaterial.paper, kg: 1, date: DateTime(2026, 5, 9));
      final r3 = await s.register(material: RecyclingMaterial.paper, kg: 1, date: today);
      expect(r3.newAchievements.map((a) => a.id), ['streak3']);
      // Otra actividad el mismo día: nada nuevo, nada repetido.
      final r4 = await s.register(material: RecyclingMaterial.paper, kg: 1, date: today);
      expect(r4.newAchievements, isEmpty);
      expect(await store.unlockedIds(), {'first', 'streak3'});
      // 5 kg acumulados -> kg5 una sola vez.
      final r5 = await s.register(material: RecyclingMaterial.paper, kg: 1, date: today);
      expect(r5.newAchievements.map((a) => a.id), ['kg5']);
    });
  });
}
