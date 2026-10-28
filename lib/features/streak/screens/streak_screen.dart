import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/services/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/widgets/eco_card.dart';
import '../../../data/models/recycling_activity.dart';
import '../../achievements/models/achievement.dart';
import '../../achievements/services/achievement_service.dart';
import '../../achievements/widgets/achievement_tile.dart';
import '../../home/widgets/streak_card.dart';
import '../../recycling/services/user_stats.dart';
import '../services/streak_calculator.dart';
import '../services/week_summary.dart';
import '../widgets/month_calendar.dart';
import '../widgets/week_dots.dart';

class StreakScreen extends ConsumerStatefulWidget {
  const StreakScreen({super.key});
  @override
  ConsumerState<StreakScreen> createState() => _StreakScreenState();
}

class _StreakScreenState extends ConsumerState<StreakScreen> {
  late DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);

  @override
  Widget build(BuildContext context) {
    final activities = ref.watch(activitiesProvider);
    final unlocked = ref.watch(unlockedIdsProvider).valueOrNull ?? <String>{};
    return SafeArea(
      child: activities.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => ErrorRetry(
            message: 'No pudimos cargar tu racha.',
            onRetry: () => ref.invalidate(activitiesProvider)),
        data: (list) => _body(context, list, unlocked),
      ),
    );
  }

  Widget _body(BuildContext context, List<RecyclingActivity> list, Set<String> unlocked) {
    final now = DateTime.now();
    final text = Theme.of(context).textTheme;
    final streak = StreakCalculator.calculate(list.map((a) => a.date), today: now);
    final stats = UserStats.from(list, today: now);
    final week = WeekSummary.of(list, now);
    final activeToday = streak.activeDays.contains(dayOnly(now));
    final next = AchievementService.next(stats, unlocked);

    final thisMonth = DateTime(now.year, now.month);
    final earliest = streak.activeDays.isEmpty
        ? thisMonth
        : DateTime(streak.activeDays.first.year, streak.activeDays.first.month);
    final canPrev = _month.isAfter(earliest);
    final canNext = _month.isBefore(thisMonth);
    final past = streak.pastRuns.reversed.take(5).toList();
    final dateFmt = DateFormat('d MMM', 'es');

    return ListView(
      padding: const EdgeInsets.all(Gaps.m),
      children: [
        Text('Tu racha',
            style: text.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: Gaps.m),
        StreakCard(current: stats.currentStreak, best: stats.bestStreak, activeToday: activeToday),
        const SizedBox(height: Gaps.m),
        EcoCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Esta semana: ${week.activeCount} de 7 días', style: text.titleMedium),
            const SizedBox(height: Gaps.s),
            WeekDots(week: week),
          ]),
        ),
        const SizedBox(height: Gaps.m),
        EcoCard(
          child: MonthCalendar(
            month: _month,
            activeDays: streak.activeDays.toSet(),
            today: now,
            onPrev: canPrev
                ? () => setState(() => _month = DateTime(_month.year, _month.month - 1))
                : null,
            onNext: canNext
                ? () => setState(() => _month = DateTime(_month.year, _month.month + 1))
                : null,
          ),
        ),
        const SizedBox(height: Gaps.m),
        if (next != null) ...[
          EcoCard(child: _NextAchievement(next: next, stats: stats)),
          const SizedBox(height: Gaps.m),
        ],
        EcoCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Rachas anteriores', style: text.titleMedium),
            const SizedBox(height: Gaps.xs),
            if (past.isEmpty)
              const Text('Aún no tienes rachas anteriores terminadas.')
            else
              for (final r in past)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text('${dateFmt.format(r.start)} – ${dateFmt.format(r.end)} · '
                      '${r.length} ${r.length == 1 ? "día" : "días"}'),
                ),
            const SizedBox(height: Gaps.xs),
            Text('Récord histórico: ${streak.best} ${streak.best == 1 ? "día" : "días"}',
                style: text.bodySmall?.copyWith(color: AppColors.grey)),
          ]),
        ),
        const SizedBox(height: Gaps.m),
        EcoCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Logros', style: text.titleMedium),
            const SizedBox(height: Gaps.xs),
            for (final a in allAchievements)
              AchievementTile(achievement: a, stats: stats, unlocked: unlocked.contains(a.id)),
          ]),
        ),
        const SizedBox(height: Gaps.m),
        Text('Los registros son declarados por ti y no se verifican automáticamente.',
            textAlign: TextAlign.center,
            style: text.bodySmall?.copyWith(color: AppColors.grey)),
      ],
    );
  }
}

class _NextAchievement extends StatelessWidget {
  const _NextAchievement({required this.next, required this.stats});
  final Achievement next;
  final UserStats stats;
  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Próximo logro', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: Gaps.xs),
          AchievementTile(achievement: next, stats: stats, unlocked: false),
        ],
      );
}
