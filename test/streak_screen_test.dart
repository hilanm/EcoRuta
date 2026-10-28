import 'package:flutter/widgets.dart' show Size;
import 'package:ecoruta/app.dart';
import 'package:ecoruta/core/services/providers.dart';
import 'package:ecoruta/data/repositories/activity_repository.dart';
import 'package:ecoruta/features/streak/services/month_grid.dart';
import 'package:ecoruta/features/streak/services/streak_messages.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() => initializeDateFormatting('es'));

  test('monthGrid: mayo 2026 empieza en viernes y tiene 31 días', () {
    final g = monthGrid(2026, 5);
    expect(g.length % 7, 0);
    expect(g.take(4).every((c) => c == null), isTrue); // lunes a jueves vacíos
    expect(g[4], DateTime.utc(2026, 5, 1));
    expect(g.whereType<DateTime>().length, 31);
    expect(g.whereType<DateTime>().last, DateTime.utc(2026, 5, 31));
  });

  test('monthGrid: febrero bisiesto y cambio de año', () {
    expect(monthGrid(2028, 2).whereType<DateTime>().length, 29);
    expect(monthGrid(2026, 12).whereType<DateTime>().last, DateTime.utc(2026, 12, 31));
  });

  test('mensajes motivacionales según estado real', () {
    expect(motivationalMessage(current: 0, best: 0, activeToday: false),
        contains('primer reciclaje'));
    expect(motivationalMessage(current: 0, best: 5, activeToday: false),
        contains('reinició'));
    expect(motivationalMessage(current: 2, best: 5, activeToday: false),
        contains('Registra hoy'));
    expect(motivationalMessage(current: 4, best: 4, activeToday: true),
        contains('mejor racha'));
  });

  testWidgets('pestaña Racha muestra calendario y logros en estado inicial', (tester) async {
    // Ventana alta: el ListView solo construye lo visible.
    tester.view.physicalSize = const Size(800, 4000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        activityRepositoryProvider.overrideWithValue(InMemoryActivityRepository()),
        achievementStoreProvider.overrideWithValue(InMemoryAchievementStore()),
      ],
      child: const EcoRutaApp(),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Racha'));
    await tester.pumpAndSettle();
    expect(find.text('Logros'), findsOneWidget);
    expect(find.text('Rachas anteriores'), findsOneWidget);
    expect(find.text('Primer reciclaje'), findsWidgets);
  });
}
