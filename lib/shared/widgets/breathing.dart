import 'dart:async';

import 'package:flutter/material.dart';

/// The gentle idle "breathing" loop shared by every mascot widget — a small
/// lift + scale pulse. Settings' "Reduce motion" plumbs through [animate];
/// [phaseOffset] delays the loop's start so multiple instances (e.g. the
/// twin pair) don't pulse in lockstep.
class Breathing extends StatefulWidget {
  const Breathing({
    super.key,
    required this.child,
    this.animate = true,
    this.phaseOffset = Duration.zero,
  });

  final Widget child;
  final bool animate;
  final Duration phaseOffset;

  @override
  State<Breathing> createState() => _BreathingState();
}

class _BreathingState extends State<Breathing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  );

  Timer? _startTimer;

  @override
  void initState() {
    super.initState();
    if (!widget.animate) return;
    // Skip the Timer entirely for the common zero-offset case — a pending
    // Future.delayed(Duration.zero) is still an unresolved Timer, and widget
    // tests that don't pumpAndSettle correctly flag it as leaked.
    if (widget.phaseOffset == Duration.zero) {
      _controller.repeat(reverse: true);
    } else {
      _startTimer = Timer(widget.phaseOffset, () {
        if (mounted) _controller.repeat(reverse: true);
      });
    }
  }

  @override
  void didUpdateWidget(covariant Breathing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate == oldWidget.animate) return;
    if (widget.animate) {
      _controller.repeat(reverse: true);
    } else {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _startTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final breathe = Curves.easeInOut.transform(_controller.value);
        return Transform.translate(
          offset: Offset(0, -2 * breathe),
          child: Transform.scale(scale: 1.0 + 0.02 * breathe, child: child),
        );
      },
      child: widget.child,
    );
  }
}
