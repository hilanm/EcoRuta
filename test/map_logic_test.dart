import 'dart:convert';
import 'package:ecoruta/data/models/recycling_material.dart';
import 'package:ecoruta/data/models/recycling_point.dart';
import 'package:ecoruta/data/repositories/recycling_point_repository.dart';
import 'package:ecoruta/features/map/services/point_filter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

RecyclingPoint pt(String id, String name, List<RecyclingMaterial> m,
        {double? lat, double? lng}) =>
    RecyclingPoint(
        id: id, name: name, address: 'Calle $id', materials: m, source: 's',
        verification: VerificationStatus.verified, latitude: lat, longitude: lng);

void main() {
  final glass = pt('1', 'Punto Vidrio', [RecyclingMaterial.glass]);
  final multi = pt('2', 'Punto Mixto', [RecyclingMaterial.plastic, RecyclingMaterial.paper]);
  final all = [glass, multi];

  test('sin filtros devuelve todos', () {
    expect(filterPoints(all, const MapFilter()).length, 2);
  });

  test('filtra por categoría: no todos aceptan todo', () {
    final r = filterPoints(all, const MapFilter(categories: {RecyclingMaterial.paper}));
    expect(r.map((p) => p.id), ['2']);
  });

  test('busca por nombre, dirección y material, sin distinguir tildes', () {
    expect(filterPoints(all, const MapFilter(query: 'vidrio')).map((p) => p.id), ['1']);
    expect(filterPoints(all, const MapFilter(query: 'calle 2')).map((p) => p.id), ['2']);
    expect(filterPoints(all, const MapFilter(query: 'PAPEL')).map((p) => p.id), ['2']);
  });

  test('coordenadas nulas o inválidas no producen ubicación', () {
    expect(glass.location, isNull);
    expect(pt('3', 'x', [RecyclingMaterial.glass], lat: 200, lng: 0).location, isNull);
    expect(pt('4', 'x', [RecyclingMaterial.glass], lat: -33.45, lng: -70.59).location,
        isNotNull);
  });

  test('distancia y formato', () {
    final d = distanceMeters(const LatLng(-33.45, -70.60), const LatLng(-33.46, -70.60));
    expect(d, closeTo(1112, 20));
    expect(formatDistance(450), '450 m');
    expect(formatDistance(1500), '1,5 km');
  });

  test('el repositorio descarta registros mal formados sin romper', () async {
    final json = jsonEncode({
      'points': [
        {'id': 'a', 'name': 'Ok', 'address': 'X', 'materials': ['glass'],
         'source': 's', 'verification': 'verified'},
        {'id': 'b', 'name': 'Sin materiales', 'address': 'X', 'materials': []},
        {'name': 'Sin id'},
      ]
    });
    final repo = AssetRecyclingPointRepository(loader: (_) async => json);
    final pts = await repo.all();
    expect(pts.length, 1);
    expect(pts.first.id, 'a');
    expect(pts.first.location, isNull);
  });
}
