import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/local_date.dart';
import '../../../shared/widgets/fanart_background.dart';
import '../../../shared/widgets/fuwa_card.dart';
import '../../../shared/widgets/section_label.dart';
import '../../habits/data/habit_colors.dart';
import '../../habits/logic/habit_providers.dart';
import '../logic/calendar_grid.dart';
import '../logic/calendar_providers.dart';

/// v1 scope: activity dots (did any habit get completed that day?) + a
/// detail list of which habits, for the selected day. No milestone badges
/// yet — those need a historical "streak crossed a threshold on date X"
/// event log, which doesn't exist until the Notifications feature writes
/// one. Showing an always-empty badge/legend for it would be worse than not
/// having it.
class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  late DateTime _month;
  late String _selectedDateKey;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
    _selectedDateKey = localDateKey(now);
  }

  void _changeMonth(int delta) {
    setState(() => _month = DateTime(_month.year, _month.month + delta));
  }

  @override
  Widget build(BuildContext context) {
    final activeDates = ref.watch(activeDatesProvider);
    final habits = ref.watch(habitsProvider);
    final todayKey = localDateKey(DateTime.now());
    final days = calendarGridDays(_month);
    final habitsOnSelectedDay = habits
        .where((h) => h.isDoneOn(_selectedDateKey))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Calendar')),
      body: FanArtBackground(
        assetPath: 'assets/pic i just add/gif fuwamoco.gif',
        child: ListView(
          padding: const EdgeInsets.all(Gap.md),
          children: [
            FuwaCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left_rounded),
                    onPressed: () => _changeMonth(-1),
                  ),
                  Text(
                    DateFormat('MMMM yyyy').format(_month),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right_rounded),
                    onPressed: () => _changeMonth(1),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Gap.md),
            FuwaCard(
              child: Column(
                children: [
                  Row(
                    children: [
                      for (final label in const [
                        'S',
                        'M',
                        'T',
                        'W',
                        'T',
                        'F',
                        'S',
                      ])
                        Expanded(
                          child: Center(
                            child: Text(
                              label,
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: AppTheme.inkFaint,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: Gap.xs),
                  GridView.count(
                    crossAxisCount: 7,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      for (final day in days)
                        _DayCell(
                          day: day,
                          inCurrentMonth: day.month == _month.month,
                          isToday: localDateKey(day) == todayKey,
                          isSelected: localDateKey(day) == _selectedDateKey,
                          hasActivity: activeDates.contains(localDateKey(day)),
                          onTap: () => setState(
                            () => _selectedDateKey = localDateKey(day),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: Gap.md),
            FuwaCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionLabel(
                    _selectedDateKey == todayKey
                        ? 'Today · ${DateFormat('MMMM d').format(DateTime.parse(_selectedDateKey))}'
                        : DateFormat(
                            'EEEE · MMMM d',
                          ).format(DateTime.parse(_selectedDateKey)),
                  ),
                  const SizedBox(height: Gap.sm),
                  if (habitsOnSelectedDay.isEmpty)
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(Corners.sm),
                          child: Image.asset(
                            'assets/fanart/birthday.png',
                            width: 32,
                            height: 32,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: Gap.sm),
                        Expanded(
                          child: Text(
                            'No rituals completed this day.',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ),
                      ],
                    )
                  else
                    for (final habit in habitsOnSelectedDay)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: habitColor(habit.colorKey),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: Gap.sm),
                            Text(
                              habit.title,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.inCurrentMonth,
    required this.isToday,
    required this.isSelected,
    required this.hasActivity,
    required this.onTap,
  });

  final DateTime day;
  final bool inCurrentMonth;
  final bool isToday;
  final bool isSelected;
  final bool hasActivity;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textColor = !inCurrentMonth
        ? AppTheme.inkFaint
        : isToday
        ? AppTheme.ink
        : Theme.of(context).colorScheme.onSurface;

    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isToday
                  ? AppTheme.yellowDeep
                  : isSelected
                  ? AppTheme.cream
                  : null,
              border: isSelected && !isToday
                  ? Border.all(color: AppTheme.creamDeep, width: 1.5)
                  : null,
            ),
            child: Text(
              '${day.day}',
              style: TextStyle(
                color: textColor,
                fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 3),
          if (hasActivity)
            Container(
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.blueDeep,
              ),
            )
          else
            const SizedBox(height: 5),
        ],
      ),
    );
  }
}
