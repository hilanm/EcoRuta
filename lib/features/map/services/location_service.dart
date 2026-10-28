import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

enum LocationFailure { serviceDisabled, denied, deniedForever, error }

class LocationResult {
  const LocationResult.ok(LatLng this.position) : failure = null;
  const LocationResult.fail(LocationFailure this.failure) : position = null;
  final LatLng? position;
  final LocationFailure? failure;

  String get message => switch (failure) {
        LocationFailure.serviceDisabled => 'La ubicación del dispositivo está desactivada.',
        LocationFailure.denied => 'No diste permiso de ubicación. El mapa sigue funcionando sin ella.',
        LocationFailure.deniedForever =>
          'El permiso de ubicación está bloqueado. Puedes activarlo en los ajustes del sistema.',
        _ => 'No se pudo obtener tu ubicación. Inténtalo de nuevo.',
      };
}

class LocationService {
  Future<LocationResult> current() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return const LocationResult.fail(LocationFailure.serviceDisabled);
      }
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied) {
        return const LocationResult.fail(LocationFailure.denied);
      }
      if (perm == LocationPermission.deniedForever) {
        return const LocationResult.fail(LocationFailure.deniedForever);
      }
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 12),
      );
      return LocationResult.ok(LatLng(pos.latitude, pos.longitude));
    } catch (_) {
      return const LocationResult.fail(LocationFailure.error);
    }
  }
}
