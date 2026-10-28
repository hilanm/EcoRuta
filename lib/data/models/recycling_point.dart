import 'package:latlong2/latlong.dart';
import 'recycling_material.dart';

enum VerificationStatus { verified, demo }

class RecyclingPoint {
  const RecyclingPoint({
    required this.id,
    required this.name,
    required this.address,
    required this.materials,
    required this.source,
    required this.verification,
    this.latitude,
    this.longitude,
    this.coordinatesVerified = false,
    this.schedule,
    this.description,
    this.phone,
    this.website,
    this.lastVerified,
    this.statusNote,
  });

  final String id, name, address, source;
  final List<RecyclingMaterial> materials;
  final VerificationStatus verification;
  final double? latitude, longitude;
  final bool coordinatesVerified;
  final String? schedule, description, phone, website, lastVerified, statusNote;

  bool get isDemo => verification == VerificationStatus.demo;

  /// Null si no hay coordenadas válidas: el punto no se dibuja en el mapa.
  LatLng? get location {
    final la = latitude, lo = longitude;
    if (la == null || lo == null) return null;
    if (la.isNaN || lo.isNaN || la < -90 || la > 90 || lo < -180 || lo > 180) {
      return null;
    }
    return LatLng(la, lo);
  }

  /// Lanza si faltan campos obligatorios; el repositorio descarta ese registro.
  factory RecyclingPoint.fromJson(Map<String, dynamic> j) {
    final mats = <RecyclingMaterial>[];
    for (final m in (j['materials'] as List? ?? const [])) {
      for (final v in RecyclingMaterial.values) {
        if (v.name == m) mats.add(v);
      }
    }
    if (mats.isEmpty) throw const FormatException('sin materiales válidos');
    return RecyclingPoint(
      id: j['id'] as String,
      name: j['name'] as String,
      address: j['address'] as String,
      materials: mats,
      source: (j['source'] as String?) ?? 'Sin fuente',
      verification: j['verification'] == 'verified'
          ? VerificationStatus.verified
          : VerificationStatus.demo,
      latitude: (j['latitude'] as num?)?.toDouble(),
      longitude: (j['longitude'] as num?)?.toDouble(),
      coordinatesVerified: j['coordinatesVerified'] == true,
      schedule: j['schedule'] as String?,
      description: j['description'] as String?,
      phone: j['phone'] as String?,
      website: j['website'] as String?,
      lastVerified: j['lastVerified'] as String?,
      statusNote: j['statusNote'] as String?,
    );
  }
}
