import '../../../core/utils/date_utils.dart';
import '../../../data/models/recycling_activity.dart';
import '../../../data/models/recycling_material.dart';

/// Filtra por categoría y rango de fechas (ambos extremos incluidos) y ordena
/// de la más reciente a la más antigua.
List<RecyclingActivity> filterHistory(List<RecyclingActivity> all,
    {RecyclingMaterial? material, DateTime? from, DateTime? to}) {
  final f = from == null ? null : dayOnly(from);
  final t = to == null ? null : dayOnly(to);
  final out = all.where((a) {
    if (material != null && a.material != material) return false;
    if (f != null && a.date.isBefore(f)) return false;
    if (t != null && a.date.isAfter(t)) return false;
    return true;
  }).toList();
  out.sort((a, b) {
    final c = b.date.compareTo(a.date);
    return c != 0 ? c : b.id.compareTo(a.id);
  });
  return out;
}
