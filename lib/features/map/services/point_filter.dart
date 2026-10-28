import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import '../../../data/models/recycling_material.dart';
import '../../../data/models/recycling_point.dart';

class MapFilter {
  const MapFilter({this.categories = const {}, this.query = ''});
  final Set<RecyclingMaterial> categories;
  final String query;
  MapFilter copyWith({Set<RecyclingMaterial>? categories, String? query}) =>
      MapFilter(categories: categories ?? this.categories, query: query ?? this.query);
}

String _fold(String s) => s
    .toLowerCase()
    .replaceAll('á', 'a').replaceAll('é', 'e').replaceAll('í', 'i')
    .replaceAll('ó', 'o').replaceAll('ú', 'u').replaceAll('ü', 'u');

/// Sin categorías = todas. Con categorías = el punto acepta al menos una.
/// La búsqueda mira nombre, dirección y materiales aceptados.
List<RecyclingPoint> filterPoints(List<RecyclingPoint> points, MapFilter f) {
  final q = _fold(f.query.trim());
  return points.where((p) {
    if (f.categories.isNotEmpty && !p.materials.any(f.categories.contains)) {
      return false;
    }
    if (q.isEmpty) return true;
    final hay = _fold('${p.name} ${p.address} ${p.materials.map((m) => m.label).join(' ')}');
    return hay.contains(q);
  }).toList();
}

double distanceMeters(LatLng a, LatLng b) =>
    const Distance().as(LengthUnit.Meter, a, b);

String formatDistance(double meters) => meters < 1000
    ? '${meters.round()} m'
    : '${NumberFormat('0.0', 'es').format(meters / 1000)} km';
