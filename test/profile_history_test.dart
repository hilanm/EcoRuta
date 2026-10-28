import 'package:flutter/material.dart';
import 'package:ecoruta/app.dart';
import 'package:ecoruta/core/services/providers.dart';
import 'package:ecoruta/data/models/recycling_activity.dart';
import 'package:ecoruta/data/models/recycling_material.dart';
import 'package:ecoruta/data/repositories/activity_repository.dart';
import 'package:ecoruta/data/repositories/prefs_repository.dart';
import 'package:ecoruta/data/repositories/profile_repository.dart';
import 'package:ecoruta/features/profile/services/profile_validation.dart';
import 'package:ecoruta/features/recycling/services/history_filter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

RecyclingActivity act(String id, DateTime d, RecyclingMaterial m) =>
    RecyclingActivity(id: id, date: d, material: m, kg: 1);

void main() {
  setUpAll(() => initializeDateFormatting('es'));

  test('validateAlias', () {
    expect(validateAlias(''), isNotNull);
    expect(validateAlias('  '), isNotNull);
    expect(validateAlias('a'), isNotNull);
    expect(validateAlias('x' * 25), isNotNull);
    expect(validateAlias('  Mapache  '), isNull);
  });

  group('filterHistory', () {
    final a = act('1', DateTime(2026, 5, 1), RecyclingMaterial.glass);
    final b = act('2', DateTime(2026, 5, 10), RecyclingMaterial.plastic);
    final c = act('3', DateTime(2026, 5, 10), RecyclingMaterial.glass);
    final all = [a, b, c];

    test('ordena de más reciente a más antigua', () {
      expect(filterHistory(all).map((x) => x.id), ['3', '2', '1']);
    });
    test('filtra por categoría', () {
      expect(
          filterHistory(all, material: RecyclingMaterial.glass)
              .map((x) => x.id),
          ['3', '1']);
    });
    test('rango de fechas con extremos incluidos', () {
      final r = filterHistory(all,
          from: DateTime(2026, 5, 10), to: DateTime(2026, 5, 10));
      expect(r.map((x) => x.id), ['3', '2']);
      expect(filterHistory(all, from: DateTime(2026, 5, 2)).length, 2);
      expect(
          filterHistory(all, to: DateTime(2026, 5, 9)).map((x) => x.id), ['1']);
    });
    test('categoría y fechas combinadas', () {
      final r = filterHistory(all,
          material: RecyclingMaterial.plastic,
          from: DateTime(2026, 5, 1),
          to: DateTime(2026, 5, 31));
      expect(r.map((x) => x.id), ['2']);
    });
  });

  test('perfil en memoria: alias por defecto, edición y reset', () async {
    final repo =
        InMemoryProfileRepository(clock: () => DateTime(2026, 5, 10, 22));
    final p = await repo.load();
    expect(p.alias, 'Reciclador');
    expect(p.createdDay, DateTime.utc(2026, 5, 10));
    await repo.saveAlias('  Mapache ');
    expect((await repo.load()).alias, 'Mapache');
    await repo.reset();
    expect((await repo.load()).alias, 'Reciclador');
  });

  testWidgets('perfil: editar alias y restablecer con confirmación',
      (tester) async {
    tester.view.physicalSize = const Size(800, 4000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final repo = InMemoryActivityRepository();
    await repo.insert(act('1', DateTime.now(), RecyclingMaterial.glass));
    final store = InMemoryAchievementStore();
    await store.unlock('first', DateTime.now());

    await tester.pumpWidget(ProviderScope(
      overrides: [
        activityRepositoryProvider.overrideWithValue(repo),
        achievementStoreProvider.overrideWithValue(store),
        profileRepositoryProvider
            .overrideWithValue(InMemoryProfileRepository()),
        prefsRepositoryProvider.overrideWithValue(InMemoryPrefsRepository()),
      ],
      child: const EcoRutaApp(),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Perfil'));
    await tester.pumpAndSettle();
    expect(find.text('Reciclador'), findsOneWidget);

    // Editar alias
    await tester.tap(find.byTooltip('Editar alias'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Mapache');
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();
    expect(find.text('Mapache'), findsOneWidget);

    // Cancelar el restablecimiento no borra nada
    await tester.tap(find.text('Restablecer datos locales'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect((await repo.all()).length, 1);

    // Confirmar borra actividades y logros
    await tester.tap(find.text('Restablecer datos locales'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Borrar todo'));
    await tester.pumpAndSettle();
    expect(await repo.all(), isEmpty);
    expect(await store.unlockedIds(), isEmpty);
  });
}
