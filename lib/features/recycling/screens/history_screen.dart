import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/services/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/eco_card.dart';
import '../../../data/models/recycling_activity.dart';
import '../../../data/models/recycling_material.dart';
import '../services/history_filter.dart';
import '../widgets/material_icons.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});
  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  RecyclingMaterial? _material;
  DateTimeRange? _range;

  Future<void> _pickRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 3),
      lastDate: now,
      initialDateRange: _range,
    );
    if (picked != null) setState(() => _range = picked);
  }

  Future<void> _delete(RecyclingActivity a) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar actividad'),
        content: const Text('Se actualizarán tus estadísticas y tu racha. '
            'Los logros ya obtenidos se conservan.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Eliminar')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(activityServiceProvider).remove(a.id);
      ref.invalidate(activitiesProvider);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Actividad eliminada.')));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('No se pudo eliminar.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final activities = ref.watch(activitiesProvider);
    final df = DateFormat('d MMM y', 'es');
    final nf = NumberFormat('0.##', 'es');
    return Scaffold(
      appBar: AppBar(title: const Text('Historial'), backgroundColor: AppColors.background),
      body: activities.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => ErrorRetry(
            message: 'No pudimos cargar el historial.',
            onRetry: () => ref.invalidate(activitiesProvider)),
        data: (all) {
          final list = filterHistory(all,
              material: _material, from: _range?.start, to: _range?.end);
          final kg = list.fold<double>(0, (s, a) => s + a.kg);
          return Column(children: [
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: Gaps.m),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: Gaps.s),
                    child: FilterChip(
                      label: const Text('Todas'),
                      selected: _material == null,
                      selectedColor: AppColors.lightGreen,
                      onSelected: (_) => setState(() => _material = null),
                    ),
                  ),
                  for (final m in RecyclingMaterial.values)
                    Padding(
                      padding: const EdgeInsets.only(right: Gaps.s),
                      child: FilterChip(
                        label: Text(m.label),
                        selected: _material == m,
                        selectedColor: AppColors.lightGreen,
                        onSelected: (_) => setState(() => _material = _material == m ? null : m),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Gaps.m),
              child: Row(children: [
                OutlinedButton.icon(
                  onPressed: _pickRange,
                  icon: const Icon(Icons.date_range),
                  label: Text(_range == null
                      ? 'Todas las fechas'
                      : '${df.format(_range!.start)} – ${df.format(_range!.end)}'),
                ),
                if (_range != null)
                  IconButton(
                      tooltip: 'Quitar filtro de fechas',
                      onPressed: () => setState(() => _range = null),
                      icon: const Icon(Icons.close)),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.all(Gaps.m),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('${list.length} ${list.length == 1 ? "actividad" : "actividades"}'
                    ' · ${nf.format(kg)} kg'),
              ),
            ),
            Expanded(
              child: list.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(Gaps.l),
                        child: Text(
                          all.isEmpty
                              ? 'Aún no has registrado actividades.'
                              : 'Ninguna actividad coincide con los filtros.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(Gaps.m, 0, Gaps.m, Gaps.m),
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const SizedBox(height: Gaps.s),
                      itemBuilder: (_, i) {
                        final a = list[i];
                        return EcoCard(
                          child: Row(children: [
                            Icon(materialIcon(a.material), color: AppColors.green),
                            const SizedBox(width: Gaps.m),
                            Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text('${a.material.label} · ${nf.format(a.kg)} kg',
                                    style: const TextStyle(fontWeight: FontWeight.w600)),
                                Text(df.format(a.date),
                                    style: const TextStyle(color: AppColors.grey, fontSize: 12)),
                                if (a.description != null) Text(a.description!),
                              ]),
                            ),
                            IconButton(
                              tooltip: 'Eliminar actividad',
                              onPressed: () => _delete(a),
                              icon: const Icon(Icons.delete_outline),
                            ),
                          ]),
                        );
                      },
                    ),
            ),
            const Padding(
              padding: EdgeInsets.all(Gaps.s),
              child: Text('Actividades declaradas por ti; no verificadas.',
                  style: TextStyle(fontSize: 12, color: AppColors.grey)),
            ),
          ]);
        },
      ),
    );
  }
}
