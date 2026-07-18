import 'package:flutter/material.dart';

/// The app's glassmorphism shape: a faint white wash, a thin bright edge,
/// and a soft shadow to lift it off whatever's underneath. The blur itself
/// lives one layer down, in [FanArtBackground] — blurring the photo/gif
/// once there instead of behind every individual card is what keeps this
/// cheap with several cards on screen at once (see that file's doc comment
/// for why: per-card `BackdropFilter` measurably stalled the renderer).
///
/// [child] is wrapped in a transparent [Material] — an [InkWell] paints its
/// ripple on the *nearest* Material ancestor, and without one sitting
/// inside the tint/border decoration, the ripple would render on whatever
/// Material is further up the tree and get visually buried under this
/// surface's own fill. Harmless when [child] has no ink to show.
class GlassSurface extends StatelessWidget {
  const GlassSurface({
    super.key,
    required this.child,
    required this.radius,
    this.padding = EdgeInsets.zero,
    this.width,
    this.tintOpacity = 0.18,
    this.borderColor,
  });

  final Widget child;
  final double radius;
  final EdgeInsets padding;
  final double? width;
  final double tintOpacity;

  /// Overrides the default bright-white edge — for call sites that use the
  /// border itself to carry state (e.g. a "done" accent color).
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: tintOpacity),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: borderColor ?? Colors.white.withValues(alpha: 0.55),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(type: MaterialType.transparency, child: child),
    );
  }
}
