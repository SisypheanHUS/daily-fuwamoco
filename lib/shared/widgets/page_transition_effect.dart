import 'package:flutter/material.dart';

/// Fires once per navigation — a page push (see [PageTransitionObserver]) or
/// a bottom-nav branch switch (see `AppShell`, which doesn't go through the
/// Navigator at all, so needs its own manual pulse). A bare [ValueNotifier]
/// rather than Riverpod: this is transient animation signaling, not app
/// state, and [PageTransitionObserver] lives outside the widget tree where a
/// `WidgetRef` isn't available.
final pageTransitionPulse = ValueNotifier<int>(0);

void pulsePageTransitionEffect() => pageTransitionPulse.value++;

/// Pulses [pageTransitionPulse] on every route push. Skips the very first
/// push (app boot) so the effect only ever plays on an actual navigation.
class PageTransitionObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute != null) pulsePageTransitionEffect();
  }
}

/// Wraps the whole app (via `MaterialApp.router`'s `builder`) with a
/// centered "hehehe fuwawa" pop, fading in/out on top of whatever's
/// underneath — the same beat as the greeting screen's reveal animations,
/// just triggered by navigation instead of app boot.
class PageTransitionEffect extends StatefulWidget {
  const PageTransitionEffect({super.key, required this.child});

  final Widget child;

  @override
  State<PageTransitionEffect> createState() => _PageTransitionEffectState();
}

class _PageTransitionEffectState extends State<PageTransitionEffect>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 650),
  );
  late final Animation<double> _opacity = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 30),
    TweenSequenceItem(tween: ConstantTween(1.0), weight: 20),
    TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 50),
  ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  late final Animation<double> _scale = Tween(
    begin: 0.7,
    end: 1.0,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

  @override
  void initState() {
    super.initState();
    pageTransitionPulse.addListener(_onPulse);
  }

  void _onPulse() {
    // PageTransitionObserver.didPush fires mid-build (Navigator calls
    // observers while updating its own widget tree) — starting the
    // controller synchronously here trips "setState called during build".
    // Defer to the frame after the navigation settles.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.forward(from: 0);
    });
  }

  @override
  void dispose() {
    pageTransitionPulse.removeListener(_onPulse);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        IgnorePointer(
          child: FadeTransition(
            opacity: _opacity,
            child: Center(
              child: ScaleTransition(
                scale: _scale,
                child: ClipOval(
                  child: Image.asset(
                    'assets/pic i just add/hehehe fuwawa smile evil.gif',
                    width: 160,
                    height: 160,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
