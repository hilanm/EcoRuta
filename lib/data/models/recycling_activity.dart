import '../../core/utils/date_utils.dart';
import 'recycling_material.dart';

/// Actividad DECLARADA por el usuario (no verificada ni certificada).
class RecyclingActivity {
  RecyclingActivity({
    required this.id,
    required DateTime date,
    required this.material,
    required this.kg,
    this.pointId,
    this.description,
    this.photoPath,
  }) : date = dayOnly(date);

  final String id;
  final DateTime date; // día local, solo fecha
  final RecyclingMaterial material;
  final double kg;
  final String? pointId;
  final String? description;
  final String? photoPath;

  Map<String, Object?> toMap() => {
        'id': id,
        'day': dayKey(date),
        'material': material.name,
        'kg': kg,
        'point_id': pointId,
        'description': description,
        'photo_path': photoPath,
      };

  factory RecyclingActivity.fromMap(Map<String, Object?> m) =>
      RecyclingActivity(
        id: m['id'] as String,
        date: parseDayKey(m['day'] as String),
        material: RecyclingMaterial.fromName(m['material'] as String),
        kg: (m['kg'] as num).toDouble(),
        pointId: m['point_id'] as String?,
        description: m['description'] as String?,
        photoPath: m['photo_path'] as String?,
      );
}
