import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/local_date.dart';
import '../../../shared/widgets/companion_mascot.dart';
import '../../../shared/widgets/fanart_background.dart';
import '../../../shared/widgets/glass_surface.dart';
import '../../habits/logic/habit_providers.dart';
import '../../settings/logic/settings_controller.dart';
import '../../streak/logic/streak_service.dart';
import '../data/daily_entry.dart';
import '../data/mood_colors.dart';
import '../logic/reflection_providers.dart';
import 'mood_picker.dart';

class EveningReflectionScreen extends ConsumerStatefulWidget {
  const EveningReflectionScreen({super.key});

  @override
  ConsumerState<EveningReflectionScreen> createState() =>
      _EveningReflectionScreenState();
}

class _EveningReflectionScreenState
    extends ConsumerState<EveningReflectionScreen> {
  final _goodThingController = TextEditingController();
  Mood _mood = Mood.calm;

  @override
  void dispose() {
    _goodThingController.dispose();
    super.dispose();
  }

  void _submit() {
    ref
        .read(todayEntryProvider.notifier)
        .saveEvening(mood: _mood, goodThing: _goodThingController.text.trim());
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = ref.watch(settingsProvider).reduceMotion;
    final textTheme = Theme.of(context).textTheme;
    final todayKey = localDateKey(DateTime.now());
    final habitsDoneToday = ref
        .watch(habitsProvider)
        .where((h) => h.isDoneOn(todayKey))
        .length;
    final morningMood = ref.watch(todayEntryProvider).morningMood;
    final streak = ref.watch(streakProvider);

    return Scaffold(
      body: FanArtBackground(
        assetPath: 'assets/fanart/twins-profile.jpg',
        tint: AppTheme.blue.withValues(alpha: 0.55),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Gap.sm,
                  vertical: Gap.sm,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                      ),
                      onPressed: () => context.pop(),
                    ),
                    Expanded(
                      child: Text(
                        'EVENING REFLECTION',
                        textAlign: TextAlign.center,
                        style: textTheme.labelMedium?.copyWith(
                          color: AppTheme.inkSoft,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: Gap.lg),
                  child: Column(
                    children: [
                      const SizedBox(height: Gap.sm),
                      CompanionMascot(
                        size: 92,
                        color: AppTheme.blueDeep,
                        sleepy: true,
                        animate: !reduceMotion,
                      ),
                      const SizedBox(height: Gap.md),
                      Text(
                        'Winding down together',
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: Gap.xs),
                      Text(
                        'A gentle look back at your day',
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppTheme.inkSoft,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: Gap.lg),
                      Row(
                        children: [
                          Expanded(
                            child: _RecapPill(
                              value: '$habitsDoneToday',
                              label: 'RITUALS',
                            ),
                          ),
                          const SizedBox(width: Gap.sm),
                          Expanded(
                            child: _RecapPill(
                              dotColor: morningMood != null
                                  ? moodColors[morningMood]
                                  : null,
                              label: 'MOOD',
                            ),
                          ),
                          const SizedBox(width: Gap.sm),
                          Expanded(
                            child: _RecapPill(
                              value: '$streak',
                              label: 'DAY STREAK',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: Gap.md),
                      _EveningField(
                        label: 'ONE GOOD THING TODAY',
                        child: TextField(
                          controller: _goodThingController,
                          decoration: const InputDecoration(
                            hintText: 'Even a small moment counts…',
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: textTheme.bodyLarge,
                        ),
                      ),
                      const SizedBox(height: Gap.md),
                      _EveningField(
                        label: 'HOW ARE YOU FEELING TONIGHT?',
                        child: Padding(
                          padding: const EdgeInsets.only(top: Gap.sm),
                          child: MoodPicker(
                            selected: _mood,
                            onChanged: (m) => setState(() => _mood = m),
                          ),
                        ),
                      ),
                      const SizedBox(height: Gap.xl),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(Gap.lg, 0, Gap.lg, Gap.lg),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.blueDeep,
                      foregroundColor: AppTheme.warmWhite,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: const StadiumBorder(),
                    ),
                    onPressed: _submit,
                    child: const Text(
                      'Good night',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecapPill extends StatelessWidget {
  const _RecapPill({this.value, this.dotColor, required this.label});

  final String? value;
  final Color? dotColor;
  final String label;

  @override
  Widget build(BuildContext context) {
    return GlassSurface(
      radius: 16,
      padding: const EdgeInsets.symmetric(vertical: Gap.md, horizontal: Gap.sm),
      child: Column(
        children: [
          if (value != null)
            Text(
              value!,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            )
          else
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: dotColor ?? AppTheme.creamDeep,
              ),
            ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppTheme.inkSoft,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _EveningField extends StatelessWidget {
  const _EveningField({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GlassSurface(
      radius: Corners.md,
      width: double.infinity,
      padding: const EdgeInsets.all(Gap.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppTheme.inkSoft,
              fontWeight: FontWeight.w700,
            ),
          ),
          child,
        ],
      ),
    );
  }
}
