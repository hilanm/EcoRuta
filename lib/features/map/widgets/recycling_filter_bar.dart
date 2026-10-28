import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/recycling_material.dart';
import '../services/point_filter.dart';

class RecyclingFilterBar extends StatelessWidget {
  const RecyclingFilterBar({
    super.key,
    required this.filter,
    required this.onQueryChanged,
    required this.onToggle,
    required this.onClear,
  });
  final MapFilter filter;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<RecyclingMaterial> onToggle;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            elevation: 2,
            borderRadius: BorderRadius.circular(14),
            child: TextField(
              onChanged: onQueryChanged,
              textInputAction: TextInputAction.search,
              decoration: const InputDecoration(
                hintText: 'Buscar por nombre, dirección o material',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          const SizedBox(height: Gaps.s),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                if (filter.categories.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(right: Gaps.s),
                    child: ActionChip(label: const Text('Limpiar'), onPressed: onClear),
                  ),
                for (final m in RecyclingMaterial.values)
                  Padding(
                    padding: const EdgeInsets.only(right: Gaps.s),
                    child: FilterChip(
                      label: Text(m.label),
                      selected: filter.categories.contains(m),
                      selectedColor: AppColors.lightGreen,
                      backgroundColor: AppColors.white,
                      onSelected: (_) => onToggle(m),
                    ),
                  ),
              ],
            ),
          ),
        ],
      );
}
