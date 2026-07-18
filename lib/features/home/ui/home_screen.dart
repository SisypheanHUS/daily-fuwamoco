import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/fuwa_card.dart';
import '../../../shared/widgets/twins_mascot.dart';
import '../../content/data/quote_repository.dart';
import '../../notifications/logic/notification_providers.dart';
import '../../reflection/logic/reflection_providers.dart';
import '../../schedule/data/schedule_repository.dart';
import '../../settings/logic/settings_controller.dart';
import '../../streak/logic/streak_service.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streak = ref.watch(streakProvider);
    final quote = ref.watch(quoteOfTheDayProvider).value;
    final nextStream = ref.watch(nextStreamProvider).value;
    final reduceMotion = ref.watch(settingsProvider).reduceMotion;
    final todayEntry = ref.watch(todayEntryProvider);
    final hasUnread = ref.watch(hasUnreadNotificationsProvider);
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(Gap.xs),
          child: TwinsMascot(mascotSize: 20, animate: !reduceMotion),
        ),
        title: const Text('Daily FUWAMOCO'),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded),
                onPressed: () => context.push('/notifications'),
              ),
              if (hasUnread)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.pinkDeep,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(Gap.md),
        children: [
          FuwaCard(
            child: Row(
              children: [
                Text('🔥', style: textTheme.headlineMedium),
                const SizedBox(width: Gap.md),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$streak day streak',
                        style: textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    Text('See you tomorrow morning!',
                        style: textTheme.bodyMedium
                            ?.copyWith(color: scheme.onSurfaceVariant)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: Gap.md),
          Text('TODAY\'S RITUALS',
              style: textTheme.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant, fontWeight: FontWeight.w700)),
          const SizedBox(height: Gap.sm),
          Row(
            children: [
              Expanded(
                child: _RitualCard(
                  title: 'Morning\ncheck-in',
                  subtitle: todayEntry.morningDone ? 'Done' : 'Not yet today',
                  done: todayEntry.morningDone,
                  onTap: () => context.push('/checkin/morning'),
                ),
              ),
              const SizedBox(width: Gap.sm),
              Expanded(
                child: _RitualCard(
                  title: 'Evening\nreflection',
                  subtitle: todayEntry.eveningDone ? 'Done' : 'Not yet today',
                  done: todayEntry.eveningDone,
                  onTap: () => context.push('/checkin/evening'),
                ),
              ),
            ],
          ),
          const SizedBox(height: Gap.md),
          FuwaCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('QUOTE OF THE DAY',
                    style: textTheme.labelSmall
                        ?.copyWith(color: scheme.onSurfaceVariant)),
                const SizedBox(height: Gap.sm),
                Text(
                  quote?.text ?? '…',
                  style: textTheme.titleMedium
                      ?.copyWith(fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
          const SizedBox(height: Gap.md),
          FuwaCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('NEXT STREAM',
                    style: textTheme.labelSmall
                        ?.copyWith(color: scheme.onSurfaceVariant)),
                const SizedBox(height: Gap.sm),
                Text(
                  nextStream == null ? 'TBA' : nextStream.title,
                  style: textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                if (nextStream != null)
                  Text(
                    DateFormat('EEEE d MMMM · HH:mm').format(nextStream.start),
                    style: textTheme.bodyMedium
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
              ],
            ),
          ),
          const SizedBox(height: Gap.md),
          _ActionCard(
            icon: Icons.replay_rounded,
            label: 'Replay this morning\'s greeting',
            onTap: () => context.push('/greeting'),
          ),
        ],
      ),
    );
  }
}

/// A tappable card for secondary actions — visually lighter than [FuwaCard]
/// so content reads first and actions read second.
class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(Corners.md),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: Gap.md,
            vertical: Gap.md,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Corners.md),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Row(
            children: [
              Icon(icon, color: scheme.primary),
              const SizedBox(width: Gap.md),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

/// One of the two fixed daily rituals on Home — distinct from the
/// user-defined habits in the Rituals tab. Tapping either opens its flow;
/// the done/not-yet state comes straight from [todayEntryProvider].
class _RitualCard extends StatelessWidget {
  const _RitualCard({
    required this.title,
    required this.subtitle,
    required this.done,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool done;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Material(
      color: done ? AppTheme.blue : AppTheme.cream,
      borderRadius: BorderRadius.circular(Corners.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(Corners.md),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(Gap.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.warmWhite,
                ),
                child: done
                    ? const Icon(Icons.check, size: 16, color: AppTheme.blueDeep)
                    : null,
              ),
              const SizedBox(height: Gap.sm),
              Text(title,
                  style:
                      textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
              Text(subtitle,
                  style: textTheme.bodySmall?.copyWith(color: AppTheme.inkSoft)),
            ],
          ),
        ),
      ),
    );
  }
}
