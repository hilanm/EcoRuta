import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/services/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/widgets/eco_card.dart';
import '../../../data/models/recycling_activity.dart';
import '../../achievements/services/achievement_service.dart';
import '../../achievements/widgets/achievement_ui.dart';
import '../../recycling/services/user_stats.dart';
import '../../streak/services/week_summary.dart';
import '../../streak/widgets/week_dots.dart';
import '../widgets/streak_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activities = ref.watch(activitiesProvider);
    final unlocked = ref.watch(unlockedIdsProvider).valueOrNull ?? <String>{};
    return SafeArea(
      child: activities.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => ErrorRetry(
          message: 'No pudimos cargar tus datos.',
          onRetry: () => ref.invalidate(activitiesProvider),
        ),
        data: (list) => _Dashboard(list: list, unlocked: unlocked),
      ),
    );
  }
}

class _Dashboard extends ConsumerWidget {
  const _Dashboard({required this.list, required this.unlocked});
  final List<RecyclingActivity> list;
  final Set<String> unlocked;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final stats = UserStats.from(list, today: now);
    final week = WeekSummary.of(list, now);
    final next = AchievementService.next(stats, unlocked);
    final activeToday = list.any((a) => daysBetween(a.date, now) == 0);
    RecyclingActivity? latest;
    for (final a in list) {
      if (latest == null || a.date.isAfter(latest.date)) latest = a;
    }
    final text = Theme.of(context).textTheme;
    final kg = NumberFormat('0.##', 'es').format(stats.totalKg);
    final alias = ref.watch(profileProvider).valueOrNull?.alias;

    return ListView(
      padding: const EdgeInsets.all(Gaps.m),
      children: [
        Text(alias == null ? '¡Hola!' : '¡Hola, $alias!', style: text.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        Text('Recicla hoy, transforma el mañana',
            style: text.bodyMedium?.copyWith(color: AppColors.grey)),
        const SizedBox(height: Gaps.m),
        StreakCard(current: stats.currentStreak, best: stats.bestStreak, activeToday: activeToday),
        const SizedBox(height: Gaps.m),
        Row(children: [
          Expanded(child: _StatTile(icon: Icons.scale, value: '$kg kg', label: 'Reciclados')),
          const SizedBox(width: Gaps.m),
          Expanded(child: _StatTile(icon: Icons.checklist, value: '${stats.activityCount}', label: 'Actividades')),
        ]),
        const SizedBox(height: Gaps.m),
        EcoCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Esta semana: ${week.activeCount} de 7 días',
                style: text.titleMedium),
            const SizedBox(height: Gaps.s),
            WeekDots(week: week),
          ]),
        ),
        const SizedBox(height: Gaps.m),
        if (next != null)
          EcoCard(
            child: Row(children: [
              Icon(achievementIcon(next.iconName), color: AppColors.orange, size: 32),
              const SizedBox(width: Gaps.m),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Próximo logro: ${next.name}', style: text.titleSmall),
                  const SizedBox(height: Gaps.xs),
                  Text(next.description, style: text.bodySmall),
                  const SizedBox(height: Gaps.s),
                  LinearProgressIndicator(
                    value: next.progress(stats),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(8),
                    color: AppColors.orange,
                    backgroundColor: AppColors.background,
                  ),
                ]),
              ),
            ]),
          ),
        const SizedBox(height: Gaps.m),
        EcoCard(
          child: latest == null
              ? const Text('Aún no registras actividades. ¡Tu primer reciclaje cuenta!')
              : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Actividad más reciente', style: text.titleSmall),
                  const SizedBox(height: Gaps.xs),
                  Text('${latest.material.label} · ${NumberFormat('0.##', 'es').format(latest.kg)} kg'),
                  Text(DateFormat('d MMM y', 'es').format(latest.date),
                      style: text.bodySmall?.copyWith(color: AppColors.grey)),
                  Text('Declarada por ti (no verificada)',
                      style: text.bodySmall?.copyWith(color: AppColors.grey)),
                ]),
        ),
        const SizedBox(height: Gaps.l),
        FilledButton.icon(
          onPressed: () => ref.read(tabIndexProvider.notifier).state = 2,
          icon: const Icon(Icons.add),
          label: const Text('Registrar reciclaje'),
        ),
        const SizedBox(height: Gaps.s),
        OutlinedButton.icon(
          onPressed: () => ref.read(tabIndexProvider.notifier).state = 1,
          icon: const Icon(Icons.map_outlined),
          label: const Text('Ver puntos de reciclaje'),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.icon, required this.value, required this.label});
  final IconData icon;
  final String value, label;
  @override
  Widget build(BuildContext context) => EcoCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, color: AppColors.green),
          const SizedBox(height: Gaps.s),
          Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(color: AppColors.grey)),
        ]),
      );
}
