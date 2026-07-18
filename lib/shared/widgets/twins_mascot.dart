import 'package:flutter/material.dart';

/// The pink + blue companion pair. Renders the user's own FUWAMOCO portrait
/// (`assets/fanart/twins-profile.jpg`) inside a circular frame, with the
/// same gentle breathing loop [CompanionMascot] uses elsewhere so "Reduce
/// motion" still has a visible effect here.
class TwinsMascot extends StatefulWidget {
  const TwinsMascot({super.key, this.mascotSize = 92, this.sleepy = false, this.animate = true});

  /// Kept for API parity with [CompanionMascot] callers; a photo has no
  /// sleepy/awake variant, so this has no visual effect here.
  final double mascotSize;
  final bool sleepy;
  final bool animate;

  @override
  State<TwinsMascot> createState() => _TwinsMascotState();
}

class _TwinsMascotState extends State<TwinsMascot> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  );

  @override
  void initState() {
    super.initState();
    if (widget.animate) _controller.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant TwinsMascot oldWidget) {
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
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final diameter = 120 * (widget.mascotSize / 92);
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final breathe = Curves.easeInOut.transform(_controller.value);
        return Transform.translate(
          offset: Offset(0, -2 * breathe),
          child: Transform.scale(scale: 1.0 + 0.02 * breathe, child: child),
        );
      },
      child: ClipOval(
        child: Image.asset(
          'assets/fanart/twins-profile.jpg',
          width: diameter,
          height: diameter,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
