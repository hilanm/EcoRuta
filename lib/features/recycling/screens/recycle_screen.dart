import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/services/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/recycling_material.dart';
import '../../achievements/widgets/achievement_ui.dart';
import '../services/activity_service.dart';
import 'history_screen.dart';

class RecycleScreen extends ConsumerStatefulWidget {
  const RecycleScreen({super.key});
  @override
  ConsumerState<RecycleScreen> createState() => _RecycleScreenState();
}

class _RecycleScreenState extends ConsumerState<RecycleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _kgCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  RecyclingMaterial? _material;
  DateTime _date = DateTime.now();
  bool _saving = false;

  @override
  void dispose() {
    _kgCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  double? _parseKg(String? t) =>
      t == null ? null : double.tryParse(t.trim().replaceAll(',', '.'));

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date.isAfter(now) ? now : _date,
      firstDate: DateTime(now.year - 3),
      lastDate: now,
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _snack(String msg) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(msg)));

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final desc = _descCtrl.text.trim();
      final res = await ref.read(activityServiceProvider).register(
            material: _material,
            kg: _parseKg(_kgCtrl.text),
            date: _date,
            description: desc.isEmpty ? null : desc,
          );
      ref.invalidate(activitiesProvider);
      ref.invalidate(unlockedIdsProvider);
      if (!mounted) return;
      _kgCtrl.clear();
      _descCtrl.clear();
      setState(() {
        _material = null;
        _date = DateTime.now();
      });
      _formKey.currentState?.reset();
      _snack('Actividad guardada. Queda como declarada por ti.');
      if (res.newAchievements.isNotEmpty) {
        var popups = true;
        try {
          popups = await ref.read(showAchievementPopupsProvider.future);
        } catch (_) {}
        if (popups && mounted) {
          await showAchievementDialog(context, res.newAchievements);
        }
      }
    } on ValidationException catch (e) {
      if (mounted) _snack(e.message);
    } catch (_) {
      if (mounted) _snack('No se pudo guardar. Inténtalo de nuevo.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(Gaps.m),
        children: [
          Row(children: [
            Expanded(
              child: Text('Registrar actividad',
                  style: text.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            ),
            IconButton(
              tooltip: 'Ver historial',
              onPressed: () => Navigator.of(context)
                  .push(MaterialPageRoute<void>(builder: (_) => const HistoryScreen())),
              icon: const Icon(Icons.history),
            ),
          ]),
          const SizedBox(height: Gaps.xs),
          Text('Los registros son declarados por ti; no se verifican automáticamente.',
              style: text.bodySmall?.copyWith(color: AppColors.grey)),
          const SizedBox(height: Gaps.m),
          Form(
            key: _formKey,
            child: Column(children: [
              DropdownButtonFormField<RecyclingMaterial>(
                initialValue: _material,
                decoration: const InputDecoration(labelText: 'Material'),
                items: [
                  for (final m in RecyclingMaterial.values)
                    DropdownMenuItem(value: m, child: Text(m.label)),
                ],
                onChanged: (v) => setState(() => _material = v),
                validator: (v) => v == null ? 'Selecciona un material.' : null,
              ),
              const SizedBox(height: Gaps.m),
              TextFormField(
                controller: _kgCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Cantidad (kg)', suffixText: 'kg'),
                validator: (v) {
                  final n = _parseKg(v);
                  if (v == null || v.trim().isEmpty) return 'Ingresa la cantidad.';
                  if (n == null || n.isNaN || n.isInfinite) return 'Ingresa un número válido.';
                  if (n <= 0) return 'Debe ser mayor que cero.';
                  return null;
                },
              ),
              const SizedBox(height: Gaps.m),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(14),
                child: InputDecorator(
                  decoration: const InputDecoration(
                      labelText: 'Fecha', suffixIcon: Icon(Icons.calendar_today)),
                  child: Text(DateFormat("EEEE d 'de' MMMM y", 'es').format(_date)),
                ),
              ),
              const SizedBox(height: Gaps.m),
              TextFormField(
                controller: _descCtrl,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Descripción (opcional)'),
              ),
            ]),
          ),
          const SizedBox(height: Gaps.l),
          FilledButton.icon(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.check),
            label: const Text('Guardar actividad'),
          ),
        ],
      ),
    );
  }
}
