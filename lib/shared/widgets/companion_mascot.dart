import 'dart:async';

import 'package:flutter/material.dart';

/// An original, abstract little companion — round body, soft ears, dot eyes.
/// Deliberately generic (no species markers, no specific palette) so it never
/// resembles a copyrighted character; it's a stand-in for real character art.
/// Idles with a gentle breathing loop; pass [size] to reuse it small (home)
/// or large (greeting hero).
class CompanionMascot extends StatefulWidget {
  const CompanionMascot({
    super.key,
    this.size = 96,
    this.color,
    this.sleepy = false,
    this.animate = true,
    this.phaseOffset = Duration.zero,
  });

  final double size;
  final Color? color;

  /// Half-closed happy eyes for the morning greeting; open round eyes elsewhere.
  final bool sleepy;

  /// Settings' "Reduce motion" plumbs through here — false freezes the
  /// mascot at its resting pose instead of running the breathing loop.
  final bool animate;

  /// Delays the start of the breathing loop — [TwinsMascot] staggers its two
  /// mascots with this so they don't bob in lockstep.
  final Duration phaseOffset;

  @override
  State<CompanionMascot> createState() => _CompanionMascotState();
}

class _CompanionMascotState extends State<CompanionMascot>
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
  void didUpdateWidget(covariant CompanionMascot oldWidget) {
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
    final color = widget.color ?? Theme.of(context).colorScheme.primary;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final breathe = Curves.easeInOut.transform(_controller.value);
        return Transform.translate(
          offset: Offset(0, -2 * breathe),
          child: Transform.scale(
            scale: 1.0 + 0.02 * breathe,
            child: child,
          ),
        );
      },
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: CustomPaint(
          painter: _CompanionPainter(color: color, sleepy: widget.sleepy),
        ),
      ),
    );
  }
}

class _CompanionPainter extends CustomPainter {
  const _CompanionPainter({required this.color, required this.sleepy});

  final Color color;
  final bool sleepy;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 + size.height * 0.04);
    final radius = size.width * 0.38;
    final body = Paint()..color = color;

    // ears — small rounded bumps peeking from behind the body
    final earRadius = radius * 0.36;
    final earPaint = Paint()..color = color;
    canvas.drawCircle(
      center + Offset(-radius * 0.62, -radius * 0.78),
      earRadius,
      earPaint,
    );
    canvas.drawCircle(
      center + Offset(radius * 0.62, -radius * 0.78),
      earRadius,
      earPaint,
    );

    // body
    canvas.drawCircle(center, radius, body);

    // blush
    final blush = Paint()..color = Colors.white.withValues(alpha: 0.35);
    canvas.drawCircle(
      center + Offset(-radius * 0.5, radius * 0.18),
      radius * 0.14,
      blush,
    );
    canvas.drawCircle(
      center + Offset(radius * 0.5, radius * 0.18),
      radius * 0.14,
      blush,
    );

    // eyes
    final eyePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.11
      ..strokeCap = StrokeCap.round;
    final eyeDotPaint = Paint()..color = Colors.white;
    final eyeOffset = Offset(radius * 0.34, -radius * 0.05);

    if (sleepy) {
      // happy closed-eye arcs, like ^ ^
      for (final side in [-1.0, 1.0]) {
        final c = center + Offset(eyeOffset.dx * side, eyeOffset.dy);
        final path = Path()
          ..moveTo(c.dx - radius * 0.14, c.dy + radius * 0.04)
          ..quadraticBezierTo(
            c.dx,
            c.dy - radius * 0.14,
            c.dx + radius * 0.14,
            c.dy + radius * 0.04,
          );
        canvas.drawPath(path, eyePaint);
      }
    } else {
      for (final side in [-1.0, 1.0]) {
        canvas.drawCircle(
          center + Offset(eyeOffset.dx * side, eyeOffset.dy),
          radius * 0.09,
          eyeDotPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CompanionPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.sleepy != sleepy;
}
