import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/local_date.dart';
import '../../../core/utils/streak_math.dart';
import '../../../shared/widgets/fuwa_card.dart';
import '../../../shared/widgets/section_label.dart';
import '../../../shared/widgets/twins_mascot.dart';
import '../../settings/logic/settings_controller.dart';
import '../data/habit.dart';
import '../data/habit_colors.dart';
import '../logic/habit_providers.dart';

/// Grouped by time-of-day, not category — matches how a ritual is actually
/// lived, not how it'd be filed away.
class HabitTrackerScreen extends ConsumerWidget {
  const HabitTrackerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rituals'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_rounded),
            color: AppTheme.yellowDeep,
            iconSize: 32,
            onPressed: () => _showAddHabitSheet(context, ref),
          ),
        ],
      ),
      body: habits.isEmpty
          ? _EmptyState(onAdd: () => _showAddHabitSheet(context, ref))
          : _HabitList(habits: habits),
    );
  }

  void _showAddHabitSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _AddHabitSheet(),
    );
  }
}

class _HabitList extends ConsumerWidget {
  const _HabitList({required this.habits});

  final List<Habit> habits;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayKey = localDateKey(DateTime.now());
    final groups = {
      HabitTimeOfDay.morning: 'Morning',
      HabitTimeOfDay.anytime: 'Anytime',
      HabitTimeOfDay.evening: 'Evening',
    };

    return ListView(
      padding: const EdgeInsets.all(Gap.md),
      children: [
        for (final entry in groups.entries)
          if (habits.any((h) => h.timeOfDay == entry.key)) ...[
            SectionLabel(entry.value),
            const SizedBox(height: Gap.sm),
            for (final habit in habits.where((h) => h.timeOfDay == entry.key))
              Padding(
                padding: const EdgeInsets.only(bottom: Gap.sm),
                child: _HabitRow(habit: habit, todayKey: todayKey),
              ),
            const SizedBox(height: Gap.sm),
          ],
      ],
    );
  }
}

class _HabitRow extends ConsumerWidget {
  const _HabitRow({required this.habit, required this.todayKey});

  final Habit habit;
  final String todayKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final done = habit.isDoneOn(todayKey);
    final streak = currentStreak(habit.completedDateKeys, todayKey);
    final subtitle = streak > 0
        ? '$streak-day streak'
        : habit.completedDateKeys.isEmpty
            ? 'Not started yet'
            : 'Streak broken — tap to restart';

    return FuwaCard(
      color: Theme.of(context).colorScheme.surface,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: habitColor(habit.colorKey),
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          const SizedBox(width: Gap.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(habit.title,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700)),
                Text(subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () =>
                ref.read(habitsProvider.notifier).toggleToday(habit.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: done ? AppTheme.yellowDeep : Colors.transparent,
                border: Border.all(
                  color: done ? AppTheme.yellowDeep : AppTheme.creamDeep,
                  width: 2,
                ),
              ),
              child: done
                  ? const Icon(Icons.check, size: 18, color: AppTheme.warmWhite)
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends ConsumerWidget {
  const _EmptyState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reduceMotion = ref.watch(settingsProvider).reduceMotion;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Gap.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TwinsMascot(mascotSize: 74, animate: !reduceMotion),
            const SizedBox(height: Gap.md),
            Text('No rituals yet',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: Gap.sm),
            Text(
              "Start with one small, cozy habit — the twins will remember it for you.",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: Gap.lg),
            FilledButton(onPressed: onAdd, child: const Text('Add your first ritual')),
          ],
        ),
      ),
    );
  }
}

class _AddHabitSheet extends ConsumerStatefulWidget {
  const _AddHabitSheet();

  @override
  ConsumerState<_AddHabitSheet> createState() => _AddHabitSheetState();
}

class _AddHabitSheetState extends ConsumerState<_AddHabitSheet> {
  final _titleController = TextEditingController();
  HabitTimeOfDay _timeOfDay = HabitTimeOfDay.morning;
  String _colorKey = habitColorSwatches.keys.first;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Scrollable, not just sized-to-content: on a short viewport (small
    // phone, or the keyboard eating half the screen) the fixed set of rows
    // below can overflow past the visible area otherwise.
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: Gap.lg,
        right: Gap.lg,
        top: Gap.lg,
        bottom: Gap.lg + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('New ritual',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: Gap.md),
          TextField(
            controller: _titleController,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'e.g. Stretch & breathe'),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: Gap.md),
          const SectionLabel('Time of day'),
          const SizedBox(height: Gap.sm),
          Wrap(
            spacing: Gap.sm,
            children: [
              for (final t in HabitTimeOfDay.values)
                ChoiceChip(
                  label: Text(t.name),
                  selected: _timeOfDay == t,
                  onSelected: (_) => setState(() => _timeOfDay = t),
                ),
            ],
          ),
          const SizedBox(height: Gap.md),
          const SectionLabel('Color'),
          const SizedBox(height: Gap.sm),
          Wrap(
            spacing: Gap.sm,
            children: [
              for (final entry in habitColorSwatches.entries)
                GestureDetector(
                  onTap: () => setState(() => _colorKey = entry.key),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: entry.value,
                      shape: BoxShape.circle,
                      border: _colorKey == entry.key
                          ? Border.all(color: AppTheme.ink, width: 2)
                          : null,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: Gap.lg),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _titleController.text.trim().isEmpty
                  ? null
                  : () {
                      ref.read(habitsProvider.notifier).add(
                            title: _titleController.text.trim(),
                            timeOfDay: _timeOfDay,
                            colorKey: _colorKey,
                          );
                      Navigator.of(context).pop();
                    },
              child: const Text('Add ritual'),
            ),
          ),
        ],
      ),
    );
  }
}
