import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/companion_mascot.dart';
import '../../../shared/widgets/fanart_background.dart';
import '../../../shared/widgets/glass_surface.dart';
import '../../settings/logic/settings_controller.dart';
import '../data/daily_entry.dart';
import '../data/prompt_repository.dart';
import '../logic/reflection_providers.dart';
import 'mood_picker.dart';

class MorningCheckinScreen extends ConsumerStatefulWidget {
  const MorningCheckinScreen({super.key});

  @override
  ConsumerState<MorningCheckinScreen> createState() =>
      _MorningCheckinScreenState();
}

class _MorningCheckinScreenState extends ConsumerState<MorningCheckinScreen> {
  final _noteController = TextEditingController();
  Mood _mood = Mood.happy;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _submit() {
    ref
        .read(todayEntryProvider.notifier)
        .saveMorning(mood: _mood, note: _noteController.text.trim());
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final chips = ref.watch(lookingForwardChipsProvider).value ?? const [];
    final reduceMotion = ref.watch(settingsProvider).reduceMotion;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: FanArtBackground(
        assetPath: 'assets/fanart/cute.jpg',
        tint: AppTheme.yellow.withValues(alpha: 0.45),
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
                        'MORNING CHECK-IN',
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
                        size: 96,
                        color: AppTheme.pinkDeep,
                        animate: !reduceMotion,
                      ),
                      const SizedBox(height: Gap.md),
                      Text(
                        'Morning, sleepyhead',
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: Gap.xs),
                      Text(
                        'How are you feeling right now?',
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppTheme.inkSoft,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: Gap.lg),
                      MoodPicker(
                        selected: _mood,
                        onChanged: (m) => setState(() => _mood = m),
                      ),
                      const SizedBox(height: Gap.lg),
                      GlassSurface(
                        radius: Corners.md,
                        width: double.infinity,
                        padding: const EdgeInsets.all(Gap.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ONE THING I\'M LOOKING FORWARD TO',
                              style: textTheme.labelSmall?.copyWith(
                                color: AppTheme.inkSoft,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: Gap.sm),
                            TextField(
                              controller: _noteController,
                              decoration: const InputDecoration(
                                hintText: 'Type a little something…',
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                              style: textTheme.bodyLarge,
                            ),
                            const SizedBox(height: Gap.md),
                            Wrap(
                              spacing: Gap.sm,
                              runSpacing: Gap.sm,
                              children: [
                                for (final chip in chips)
                                  ActionChip(
                                    label: Text(chip),
                                    backgroundColor: AppTheme.cream,
                                    onPressed: () => setState(
                                      () => _noteController.text = chip,
                                    ),
                                  ),
                              ],
                            ),
                          ],
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
                      backgroundColor: AppTheme.yellowDeep,
                      foregroundColor: AppTheme.ink,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: const StadiumBorder(),
                    ),
                    onPressed: _submit,
                    child: const Text(
                      'Start my day',
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
