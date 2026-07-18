import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'companion_mascot.dart';

/// The pink + blue companion pair, reusing [CompanionMascot] entirely rather
/// than duplicating its painter. Proportions match the approved mockups'
/// `.twins`/`.mascot` CSS: each mascot is ~54% of the pair's bounding box,
/// offset diagonally, blue staggered half a second behind pink so they don't
/// bob in lockstep.
class TwinsMascot extends StatelessWidget {
  const TwinsMascot({super.key, this.mascotSize = 92, this.sleepy = false, this.animate = true});

  /// Diameter of each individual mascot (matches [CompanionMascot.size]).
  final double mascotSize;
  final bool sleepy;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final scale = mascotSize / 92;
    final width = 170 * scale;
    final height = 120 * scale;
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          Positioned(
            left: 4 * scale,
            top: 16 * scale,
            child: CompanionMascot(
              size: mascotSize,
              color: AppTheme.pinkDeep,
              sleepy: sleepy,
              animate: animate,
            ),
          ),
          Positioned(
            right: 4 * scale,
            top: 6 * scale,
            child: CompanionMascot(
              size: mascotSize,
              color: AppTheme.blueDeep,
              sleepy: sleepy,
              animate: animate,
              phaseOffset: const Duration(milliseconds: 500),
            ),
          ),
        ],
      ),
    );
  }
}
