import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/recycling_point.dart';
import '../services/point_filter.dart';

class RecyclingPointDetailSheet extends StatelessWidget {
  const RecyclingPointDetailSheet({super.key, required this.point, this.userLocation});
  final RecyclingPoint point;
  final LatLng? userLocation;

  Future<void> _open(BuildContext context, Uri uri) async {
    bool ok;
    try {
      ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      ok = false;
    }
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir la aplicación externa.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final loc = point.location;
    final dist = (loc != null && userLocation != null)
        ? formatDistance(distanceMeters(userLocation!, loc))
        : null;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(Gaps.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(point.name, style: text.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: Gaps.xs),
            Chip(
              avatar: Icon(point.isDemo ? Icons.science_outlined : Icons.verified_outlined,
                  size: 18, color: point.isDemo ? AppColors.orange : AppColors.green),
              label: Text(point.isDemo ? 'Dato de demostración' : 'Fuente oficial'),
            ),
            const SizedBox(height: Gaps.s),
            Text(point.address),
            if (dist != null) Text('A unos $dist de ti (distancia en línea recta)'),
            if (loc == null)
              Text('Ubicación en el mapa aún sin verificar.',
                  style: text.bodySmall?.copyWith(color: AppColors.grey)),
            if (point.statusNote != null) ...[
              const SizedBox(height: Gaps.s),
              Container(
                padding: const EdgeInsets.all(Gaps.s),
                decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0), borderRadius: BorderRadius.circular(12)),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Icon(Icons.warning_amber_rounded, color: AppColors.orange),
                  const SizedBox(width: Gaps.s),
                  Expanded(child: Text(point.statusNote!)),
                ]),
              ),
            ],
            const SizedBox(height: Gaps.s),
            Text('Materiales aceptados', style: text.titleSmall),
            Wrap(spacing: Gaps.s, children: [
              for (final m in point.materials) Chip(label: Text(m.label)),
            ]),
            const SizedBox(height: Gaps.xs),
            Text(point.schedule == null ? 'Horario: no verificado' : 'Horario: ${point.schedule}'),
            if (point.description != null) ...[
              const SizedBox(height: Gaps.xs),
              Text(point.description!),
            ],
            if (point.phone != null) Text('Teléfono: ${point.phone}'),
            const SizedBox(height: Gaps.s),
            Text(
              'Fuente: ${point.source}'
              '${point.lastVerified != null ? " · consultada el ${point.lastVerified}" : ""}',
              style: text.bodySmall?.copyWith(color: AppColors.grey),
            ),
            const SizedBox(height: Gaps.m),
            FilledButton.icon(
              onPressed: loc == null
                  ? null
                  : () => _open(
                      context,
                      Uri.parse('https://www.google.com/maps/dir/?api=1&destination='
                          '${loc.latitude},${loc.longitude}')),
              icon: const Icon(Icons.directions),
              label: Text(loc == null ? 'Indicaciones no disponibles' : 'Cómo llegar'),
            ),
            if (point.website != null) ...[
              const SizedBox(height: Gaps.s),
              OutlinedButton.icon(
                onPressed: () {
                  final u = Uri.tryParse(point.website!);
                  if (u != null) _open(context, u);
                },
                icon: const Icon(Icons.open_in_new),
                label: const Text('Ver información oficial'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
