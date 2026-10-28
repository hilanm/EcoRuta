import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/recycling_point.dart';

/// Centro aproximado de Ñuñoa (solo vista inicial del mapa, no es un dato de punto).
const nunoaCenter = LatLng(-33.4569, -70.5976);

class RecyclingMapWidget extends StatelessWidget {
  const RecyclingMapWidget({
    super.key,
    required this.controller,
    required this.points,
    required this.userLocation,
    required this.onSelect,
    required this.onTileError,
  });
  final MapController controller;
  final List<RecyclingPoint> points;
  final LatLng? userLocation;
  final ValueChanged<RecyclingPoint> onSelect;
  final VoidCallback onTileError;

  @override
  Widget build(BuildContext context) {
    final markers = <Marker>[
      for (final p in points)
        if (p.location != null)
          Marker(
            point: p.location!,
            width: 48,
            height: 48,
            child: Semantics(
              button: true,
              label: '${p.name}${p.isDemo ? ", dato de demostración" : ""}',
              child: GestureDetector(
                onTap: () => onSelect(p),
                child: Icon(Icons.location_on,
                    size: 44, color: p.isDemo ? AppColors.orange : AppColors.green),
              ),
            ),
          ),
      if (userLocation != null)
        Marker(
          point: userLocation!,
          width: 28,
          height: 28,
          child: Semantics(
            label: 'Tu ubicación',
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1976D2),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.white, width: 3),
              ),
            ),
          ),
        ),
    ];

    return FlutterMap(
      mapController: controller,
      options: const MapOptions(
        initialCenter: nunoaCenter,
        initialZoom: 14,
        minZoom: 10,
        maxZoom: 19,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'cl.ecoruta.app',
          errorTileCallback: (tile, error, stack) => onTileError(),
        ),
        MarkerLayer(markers: markers),
        RichAttributionWidget(
          attributions: [
            TextSourceAttribution(
              '© Colaboradores de OpenStreetMap',
              onTap: () => launchUrl(
                  Uri.parse('https://www.openstreetmap.org/copyright'),
                  mode: LaunchMode.externalApplication),
            ),
          ],
        ),
      ],
    );
  }
}
