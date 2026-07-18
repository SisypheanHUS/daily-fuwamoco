import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/fuwa_card.dart';
import '../../../shared/widgets/twins_mascot.dart';
import '../../content/data/quote_repository.dart';
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
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(Gap.xs),
          child: TwinsMascot(mascotSize: 20, animate: !reduceMotion),
        ),
        title: const Text('Daily FUWAMOCO'),
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
