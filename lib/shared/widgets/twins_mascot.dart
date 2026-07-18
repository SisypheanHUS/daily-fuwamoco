import 'package:flutter/material.dart';

import 'breathing.dart';

/// The pink + blue companion pair. Renders the user's own FUWAMOCO portrait
/// (`assets/fanart/twins-profile.jpg`) inside a circular frame, with the
/// same gentle breathing loop ([Breathing]) [CompanionMascot] uses elsewhere
/// so "Reduce motion" still has a visible effect here.
class TwinsMascot extends StatelessWidget {
  const TwinsMascot({
    super.key,
    this.mascotSize = 92,
    this.sleepy = false,
    this.animate = true,
  });

  /// Kept for API parity with [CompanionMascot] callers; a photo has no
  /// sleepy/awake variant, so this has no visual effect here.
  final double mascotSize;
  final bool sleepy;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final diameter = 120 * (mascotSize / 92);
    return Breathing(
      animate: animate,
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
