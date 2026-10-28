import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/services/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/eco_card.dart';
import '../../achievements/models/achievement.dart';
import '../../achievements/widgets/achievement_ui.dart';
import '../../recycling/services/user_stats.dart';
import '../services/profile_validation.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activities = ref.watch(activitiesProvider);
    return SafeArea(
      child: activities.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => ErrorRetry(
            message: 'No pudimos cargar tu perfil.',
            onRetry: () => ref.invalidate(activitiesProvider)),
        data: (list) =>
            _Body(stats: UserStats.from(list, today: DateTime.now())),
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.stats});
  final UserStats stats;

  void _snack(BuildContext c, String m) => ScaffoldMessenger.of(c)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(m)));

  Future<void> _editAlias(
      BuildContext context, WidgetRef ref, String current) async {
    final alias = await showDialog<String>(
        context: context, builder: (_) => _AliasDialog(initial: current));
    if (alias == null) return;
    try {
      await ref.read(profileRepositoryProvider).saveAlias(alias);
      ref.invalidate(profileProvider);
    } catch (_) {
      if (context.mounted) _snack(context, 'No se pudo guardar el alias.');
    }
  }

  Future<void> _reset(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restablecer datos'),
        content: const Text(
            'Se borrarán todas tus actividades, tu racha, tus logros y '
            'tu alias de este dispositivo. Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: AppColors.error,
                minimumSize: const Size(100, 40)),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Borrar todo'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(activityRepositoryProvider).clear();
      await ref.read(achievementStoreProvider).clear();
      await ref.read(profileRepositoryProvider).reset();
      ref.invalidate(activitiesProvider);
      ref.invalidate(unlockedIdsProvider);
      ref.invalidate(profileProvider);
      if (context.mounted) _snack(context, 'Datos restablecidos.');
    } catch (_) {
      if (context.mounted)
        _snack(context, 'No se pudieron restablecer los datos.');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final profile = ref.watch(profileProvider).valueOrNull;
    final alias = profile?.alias ?? defaultAliasFallback;
    final unlocked = ref.watch(unlockedIdsProvider).valueOrNull ?? <String>{};
    final popups = ref.watch(showAchievementPopupsProvider).valueOrNull ?? true;
    final nf = NumberFormat('0.##', 'es');
    final won = allAchievements.where((a) => unlocked.contains(a.id)).toList();

    return ListView(
      padding: const EdgeInsets.all(Gaps.m),
      children: [
        Text('Perfil',
            style: text.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: Gaps.m),
        EcoCard(
          child: Row(children: [
            const CircleAvatar(
                radius: 32,
                backgroundColor: AppColors.lightGreen,
                child: Icon(Icons.eco, size: 36, color: AppColors.darkGreen)),
            const SizedBox(width: Gaps.m),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(alias,
                        style: text.titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    Text(
                      profile == null
                          ? ' '
                          : 'Desde el ${DateFormat('d MMM y', 'es').format(profile.createdDay)}',
                      style: const TextStyle(color: AppColors.grey),
                    ),
                  ]),
            ),
            IconButton(
              tooltip: 'Editar alias',
              onPressed: () => _editAlias(context, ref, alias),
              icon: const Icon(Icons.edit),
            ),
          ]),
        ),
        const SizedBox(height: Gaps.m),
        Row(children: [
          Expanded(
              child: _Metric(
                  icon: Icons.local_fire_department,
                  value: '${stats.currentStreak}',
                  label: 'Racha actual')),
          const SizedBox(width: Gaps.m),
          Expanded(
              child: _Metric(
                  icon: Icons.emoji_events,
                  value: '${stats.bestStreak}',
                  label: 'Récord de racha')),
        ]),
        const SizedBox(height: Gaps.m),
        Row(children: [
          Expanded(
              child: _Metric(
                  icon: Icons.checklist,
                  value: '${stats.activityCount}',
                  label: 'Actividades')),
          const SizedBox(width: Gaps.m),
          Expanded(
              child: _Metric(
                  icon: Icons.scale,
                  value: '${nf.format(stats.totalKg)} kg',
                  label: 'Registrados')),
        ]),
        const SizedBox(height: Gaps.m),
        EcoCard(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Logros: ${won.length} de ${allAchievements.length}',
                style: text.titleMedium),
            const SizedBox(height: Gaps.s),
            if (won.isEmpty)
              const Text(
                  'Aún no desbloqueas logros. ¡Registra tu primer reciclaje!')
            else
              Wrap(spacing: Gaps.s, runSpacing: Gaps.s, children: [
                for (final a in won)
                  Chip(
                      avatar: Icon(achievementIcon(a.iconName),
                          size: 18, color: AppColors.orange),
                      label: Text(a.name)),
              ]),
          ]),
        ),
        const SizedBox(height: Gaps.m),
        EcoCard(
          padding:
              const EdgeInsets.symmetric(horizontal: Gaps.m, vertical: Gaps.xs),
          child: Material(
            type: MaterialType.transparency,
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Avisar al desbloquear logros'),
              subtitle:
                  const Text('Muestra un mensaje al conseguir un logro nuevo.'),
              value: popups,
              onChanged: (v) async {
                try {
                  await ref
                      .read(prefsRepositoryProvider)
                      .setShowAchievementPopups(v);
                  ref.invalidate(showAchievementPopupsProvider);
                } catch (_) {
                  if (context.mounted)
                    _snack(context, 'No se pudo guardar la preferencia.');
                }
              },
            ),
          ),
        ),
        const SizedBox(height: Gaps.m),
        EcoCard(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Datos y privacidad', style: text.titleMedium),
            const SizedBox(height: Gaps.xs),
            const Text(
                'Tus datos se guardan solo en este dispositivo. No hay cuenta '
                'ni servidor, y los registros son declarados por ti.'),
            const SizedBox(height: Gaps.m),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
              onPressed: () => _reset(context, ref),
              icon: const Icon(Icons.delete_forever),
              label: const Text('Restablecer datos locales'),
            ),
          ]),
        ),
        const SizedBox(height: Gaps.m),
        Text('EcoRuta 0.1.0 · Recicla hoy, transforma el mañana',
            textAlign: TextAlign.center,
            style: text.bodySmall?.copyWith(color: AppColors.grey)),
      ],
    );
  }
}

const defaultAliasFallback = 'Reciclador';

class _Metric extends StatelessWidget {
  const _Metric({required this.icon, required this.value, required this.label});
  final IconData icon;
  final String value, label;
  @override
  Widget build(BuildContext context) => EcoCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, color: AppColors.green),
          const SizedBox(height: Gaps.s),
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(color: AppColors.grey)),
        ]),
      );
}

class _AliasDialog extends StatefulWidget {
  const _AliasDialog({required this.initial});
  final String initial;
  @override
  State<_AliasDialog> createState() => _AliasDialogState();
}

class _AliasDialogState extends State<_AliasDialog> {
  late final TextEditingController _ctrl =
      TextEditingController(text: widget.initial);
  final _key = GlobalKey<FormState>();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Editar alias'),
        content: Form(
          key: _key,
          child: TextFormField(
            controller: _ctrl,
            autofocus: true,
            maxLength: 24,
            decoration: const InputDecoration(labelText: 'Alias'),
            validator: validateAlias,
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(100, 40)),
            onPressed: () {
              if (_key.currentState!.validate())
                Navigator.pop(context, _ctrl.text.trim());
            },
            child: const Text('Guardar'),
          ),
        ],
      );
}
