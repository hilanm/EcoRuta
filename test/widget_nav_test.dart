import 'package:ecoruta/app.dart';
import 'package:ecoruta/core/services/providers.dart';
import 'package:ecoruta/data/repositories/activity_repository.dart';
import 'package:ecoruta/features/streak/services/week_summary.dart';
import 'package:ecoruta/data/models/recycling_activity.dart';
import 'package:ecoruta/data/models/recycling_material.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() => initializeDateFormatting('es'));

  Widget app() => ProviderScope(
        overrides: [
          activityRepositoryProvider.overrideWithValue(InMemoryActivityRepository()),
          achievementStoreProvider.overrideWithValue(InMemoryAchievementStore()),
        ],
        child: const EcoRutaApp(),
      );

  testWidgets('navegación inferior con 5 secciones y estado inicial en cero', (tester) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    expect(find.byType(NavigationDestination), findsNWidgets(5));
    expect(find.text('0 días'), findsOneWidget);
    expect(find.text('0 kg'), findsOneWidget);
    await tester.tap(find.text('Reciclar'));
    await tester.pumpAndSettle();
    expect(find.text('Registrar actividad'), findsOneWidget);
  });

  test('WeekSummary marca los días activos de la semana (lunes a domingo)', () {
    final wed = DateTime(2026, 5, 13, 10); // miércoles
    final acts = [
      RecyclingActivity(id: '1', date: DateTime(2026, 5, 11), material: RecyclingMaterial.glass, kg: 1),
      RecyclingActivity(id: '2', date: DateTime(2026, 5, 4), material: RecyclingMaterial.glass, kg: 1),
    ];
    final w = WeekSummary.of(acts, wed);
    expect(w.todayIndex, 2);
    expect(w.active, [true, false, false, false, false, false, false]);
    expect(w.activeCount, 1);
  });
}
