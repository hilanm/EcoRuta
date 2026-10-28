import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/recycling_point.dart';

abstract class RecyclingPointRepository {
  Future<List<RecyclingPoint>> all();
}

/// Carga los puntos desde un JSON local. Agregar puntos = editar el JSON.
class AssetRecyclingPointRepository implements RecyclingPointRepository {
  AssetRecyclingPointRepository(
      {Future<String> Function(String)? loader,
      this.path = 'assets/data/recycling_points.json'})
      : _loader = loader ?? rootBundle.loadString;
  final Future<String> Function(String) _loader;
  final String path;

  @override
  Future<List<RecyclingPoint>> all() async {
    final raw = jsonDecode(await _loader(path)) as Map<String, dynamic>;
    final out = <RecyclingPoint>[];
    for (final item in (raw['points'] as List? ?? const [])) {
      try {
        out.add(RecyclingPoint.fromJson(item as Map<String, dynamic>));
      } catch (_) {
        // Un registro mal formado no debe romper el mapa.
      }
    }
    return out;
  }
}
