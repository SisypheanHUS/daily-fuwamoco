import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/local_date.dart';
import '../../content/data/quote_repository.dart';
import '../../content/data/wallpaper_repository.dart';
import '../../schedule/data/schedule_repository.dart';
import '../../settings/logic/settings_controller.dart';
import '../../streak/logic/streak_service.dart';
import '../../../shared/widgets/twins_mascot.dart';
import '../../../shared/widgets/wallpaper_background.dart';
import '../data/greeting_context.dart';
import '../logic/greeting_providers.dart';

/// The morning sequence (PRD §5):
/// fade-in → "Good Morning, Ruffian." → voice → wallpaper → quote → streak/next stream.
/// Whole run ≤ ~6.5s, any tap skips straight to home.
class GreetingScreen extends ConsumerStatefulWidget {
  const GreetingScreen({super.key});

  @override
  ConsumerState<GreetingScreen> createState() => _GreetingScreenState();
}

class _GreetingScreenState extends ConsumerState<GreetingScreen>
    with SingleTickerProviderStateMixin {
  static const _sequence = Duration(milliseconds: 4200);
  static const _autoLeaveAfter = Duration(milliseconds: 6500);

  late final AnimationController _controller;
  late final Animation<double> _fadeIn;
  late final Animation<double> _mascotIn;
  late final Animation<double> _titleIn;
  late final Animation<double> _quoteIn;
  late final Animation<double> _footerIn;
  Timer? _autoLeave;
  bool _left = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _sequence);
    _fadeIn = _slice(0.00, 0.15);
    _mascotIn = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.05, 0.32, curve: Curves.elasticOut),
    );
    _titleIn = _slice(0.20, 0.42);
    _quoteIn = _slice(0.48, 0.70);
    _footerIn = _slice(0.72, 0.95);

    final todayKey = localDateKey(DateTime.now());
    // Persist "started" immediately — killing the app mid-animation must not
    // cause a replay tomorrow-morning-style loop (PRD §5, §8.2).
    ref.read(greetingGateProvider).markStarted(todayKey);

    _controller.forward();
    _playVoice();
    _autoLeave = Timer(_autoLeaveAfter, _goHome);
  }

  Animation<double> _slice(double from, double to) => CurvedAnimation(
    parent: _controller,
    curve: Interval(from, to, curve: Curves.easeOut),
  );

  Future<void> _playVoice() async {
    final settings = ref.read(settingsProvider);
    if (!settings.audioAllowed) return; // muteAll > enabled (PRD §7)

    final pack = await ref.read(greetingPackProvider.future);
    final provider = ref.read(greetingContentProvider);
    final eligible = provider.getEligibleClips(
      GreetingContext(date: DateTime.now()),
      pack.clips,
    );
    final clip = provider.pickOne(eligible, random: settings.randomGreeting);
    if (clip == null || !mounted) return; // empty pool → visual-only (AC 5)

    await ref
        .read(greetingAudioProvider)
        .play(pack, clip, volume: settings.greetingVolume);
  }

  void _goHome() {
    if (_left || !mounted) return;
    _left = true;
    ref.read(greetingGateProvider).markCompleted(localDateKey(DateTime.now()));
    context.go('/home');
  }

  @override
  void dispose() {
    _autoLeave?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wallpaper = ref.watch(wallpaperOfTheDayProvider).value;
    final quote = ref.watch(quoteOfTheDayProvider).value;
    final streak = ref.watch(streakProvider);
    final nextStream = ref.watch(nextStreamProvider).value;
    final reduceMotion = ref.watch(settingsProvider).reduceMotion;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _goHome,
        child: WallpaperBackground(
          wallpaper: wallpaper,
          child: FadeTransition(
            opacity: _fadeIn,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(Gap.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),
                    ScaleTransition(
                      scale: _mascotIn,
                      child: TwinsMascot(
                        mascotSize: 92,
                        sleepy: true,
                        animate: !reduceMotion,
                      ),
                    ),
                    const SizedBox(height: Gap.lg),
                    _Reveal(
                      animation: _titleIn,
                      child: Text(
                        'Good Morning,\nRuffian.',
                        textAlign: TextAlign.center,
                        style: textTheme.displaySmall?.copyWith(
                          color: AppTheme.ink,
                          fontWeight: FontWeight.w700,
                          height: 1.15,
                        ),
                      ),
                    ),
                    const SizedBox(height: Gap.lg),
                    if (quote != null)
                      _Reveal(
                        animation: _quoteIn,
                        child: Text(
                          quote.text,
                          textAlign: TextAlign.center,
                          style: textTheme.titleMedium?.copyWith(
                            color: AppTheme.inkSoft,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    const Spacer(flex: 3),
                    _Reveal(
                      animation: _footerIn,
                      child: _FooterInfo(streak: streak, next: nextStream),
                    ),
                    const SizedBox(height: Gap.md),
                    _Reveal(
                      animation: _footerIn,
                      child: Text(
                        'tap to continue',
                        style: textTheme.bodySmall?.copyWith(
                          color: AppTheme.inkFaint,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Fade + gentle upward slide, shared by every staged element.
class _Reveal extends StatelessWidget {
  const _Reveal({required this.animation, required this.child});

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: AnimatedBuilder(
        animation: animation,
        builder: (_, c) => Transform.translate(
          offset: Offset(0, 12 * (1 - animation.value)),
          child: c,
        ),
        child: child,
      ),
    );
  }
}

class _FooterInfo extends StatelessWidget {
  const _FooterInfo({required this.streak, required this.next});

  final int streak;
  final StreamEvent? next;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyLarge?.copyWith(
      color: AppTheme.ink,
      fontWeight: FontWeight.w600,
    );
    final nextLabel = next == null
        ? 'Next stream: TBA'
        : 'Next stream: ${next!.title} · ${DateFormat('EEE d MMM, HH:mm').format(next!.start)}';
    return Column(
      children: [
        Text('🔥 $streak day streak', style: style),
        const SizedBox(height: Gap.xs),
        Text(nextLabel, style: style, textAlign: TextAlign.center),
      ],
    );
  }
}
