import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../../data/models/recycling_point.dart';
import '../../../data/repositories/recycling_point_repository.dart';
import 'location_service.dart';
import 'point_filter.dart';

final recyclingPointRepositoryProvider = Provider<RecyclingPointRepository>(
    (ref) => AssetRecyclingPointRepository());

final recyclingPointsProvider = FutureProvider<List<RecyclingPoint>>(
    (ref) => ref.watch(recyclingPointRepositoryProvider).all());

final mapFilterProvider = StateProvider<MapFilter>((ref) => const MapFilter());

final userLocationProvider = StateProvider<LatLng?>((ref) => null);

final locationServiceProvider = Provider<LocationService>((ref) => LocationService());

final filteredPointsProvider = Provider<AsyncValue<List<RecyclingPoint>>>((ref) {
  final f = ref.watch(mapFilterProvider);
  return ref.watch(recyclingPointsProvider).whenData((p) => filterPoints(p, f));
});
