import 'package:flutter/material.dart';
import '../../../data/models/recycling_material.dart';

IconData materialIcon(RecyclingMaterial m) => switch (m) {
      RecyclingMaterial.plastic => Icons.local_drink,
      RecyclingMaterial.glass => Icons.wine_bar,
      RecyclingMaterial.paper => Icons.description,
      RecyclingMaterial.metal => Icons.inventory_2,
      RecyclingMaterial.electronic => Icons.devices,
      RecyclingMaterial.batteries => Icons.battery_charging_full,
      RecyclingMaterial.oil => Icons.opacity,
      RecyclingMaterial.textile => Icons.checkroom,
    };
