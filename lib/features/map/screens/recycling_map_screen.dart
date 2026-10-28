import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/eco_card.dart';
import '../../../data/models/recycling_point.dart';
import '../services/map_providers.dart';
import '../widgets/recycling_filter_bar.dart';
import '../widgets/recycling_map_widget.dart';
import '../widgets/recycling_point_detail_sheet.dart';

class RecyclingMapScreen extends ConsumerStatefulWidget {
  const RecyclingMapScreen({super.key});
  @override
  ConsumerState<RecyclingMapScreen> createState() => _State();
}

class _State extends ConsumerState<RecyclingMapScreen> {
  final _controller = MapController();
  bool _tileError = false;
  bool _locating = false;

  void _snack(String msg) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(msg)));

  void _showPoint(RecyclingPoint p) => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (_) => RecyclingPointDetailSheet(
            point: p, userLocation: ref.read(userLocationProvider)),
      );

  Future<void> _locate() async {
    if (ref.read(userLocationProvider) == null) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Usar tu ubicación'),
          content: const Text(
              'EcoRuta usa tu ubicación solo para mostrarte en el mapa y calcular '
              'distancias a los puntos. No se guarda ni se envía a ningún servidor.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Ahora no')),
            FilledButton(
                style: FilledButton.styleFrom(minimumSize: const Size(100, 40)),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Continuar')),
          ],
        ),
      );
      if (ok != true) return;
    }
    setState(() => _locating = true);
    final r = await ref.read(locationServiceProvider).current();
    if (!mounted) return;
    setState(() => _locating = false);
    final pos = r.position;
    if (pos != null) {
      ref.read(userLocationProvider.notifier).state = pos;
      _controller.move(pos, 16);
    } else {
      _snack(r.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(mapFilterProvider);
    final all = ref.watch(recyclingPointsProvider);
    final filtered = ref.watch(filteredPointsProvider);
    final user = ref.watch(userLocationProvider);

    return filtered.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => ErrorRetry(
          message: 'No pudimos cargar los puntos de reciclaje.',
          onRetry: () => ref.invalidate(recyclingPointsProvider)),
      data: (points) {
        final noCoords = points.where((p) => p.location == null).toList();
        return Stack(children: [
          Positioned.fill(
            child: RecyclingMapWidget(
              controller: _controller,
              points: points,
              userLocation: user,
              onSelect: _showPoint,
              onTileError: () {
                if (!_tileError && mounted) setState(() => _tileError = true);
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(Gaps.s),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                RecyclingFilterBar(
                  filter: filter,
                  onQueryChanged: (q) => ref.read(mapFilterProvider.notifier).state =
                      filter.copyWith(query: q),
                  onToggle: (m) {
                    final s = {...ref.read(mapFilterProvider).categories};
                    s.contains(m) ? s.remove(m) : s.add(m);
                    ref.read(mapFilterProvider.notifier).state =
                        ref.read(mapFilterProvider).copyWith(categories: s);
                  },
                  onClear: () => ref.read(mapFilterProvider.notifier).state =
                      filter.copyWith(categories: {}),
                ),
                if (_tileError)
                  Padding(
                    padding: const EdgeInsets.only(top: Gaps.s),
                    child: EcoCard(
                      color: const Color(0xFFFFF3E0),
                      child: Row(children: [
                        const Icon(Icons.wifi_off, color: AppColors.orange),
                        const SizedBox(width: Gaps.s),
                        const Expanded(
                            child: Text('No se pudo cargar el mapa. Revisa tu conexión; '
                                'la lista de puntos sigue disponible.')),
                        IconButton(
                            tooltip: 'Cerrar aviso',
                            onPressed: () => setState(() => _tileError = false),
                            icon: const Icon(Icons.close)),
                      ]),
                    ),
                  ),
              ]),
            ),
          ),
          Positioned(
            left: Gaps.s,
            right: Gaps.s,
            bottom: Gaps.s,
            child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Expanded(
                child: points.isEmpty
                    ? EcoCard(
                        child: Text(all.valueOrNull?.isEmpty ?? false
                            ? 'Aún no hay puntos cargados.'
                            : 'Ningún punto coincide con tu búsqueda o filtros.'))
                    : noCoords.isEmpty
                        ? const SizedBox.shrink()
                        : FilledButton.icon(
                            onPressed: () => _showUnplaced(noCoords),
                            icon: const Icon(Icons.list_alt),
                            label: Text('${noCoords.length} punto(s) sin ubicación en el mapa'),
                          ),
              ),
              const SizedBox(width: Gaps.s),
              FloatingActionButton(
                tooltip: 'Centrar en mi ubicación',
                onPressed: _locating ? null : _locate,
                child: _locating
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.my_location),
              ),
            ]),
          ),
        ]);
      },
    );
  }

  void _showUnplaced(List<RecyclingPoint> list) => showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (_) => SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(Gaps.m),
            children: [
              Text('Puntos sin coordenadas verificadas',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: Gaps.xs),
              const Text('Son puntos con dirección de fuente oficial, pero sin '
                  'coordenadas confirmadas, por eso no aparecen como marcador.'),
              for (final p in list)
                ListTile(
                  title: Text(p.name),
                  subtitle: Text(p.address),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pop(context);
                    _showPoint(p);
                  },
                ),
            ],
          ),
        ),
      );
}
