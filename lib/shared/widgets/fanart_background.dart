import 'dart:ui';

import 'package:flutter/material.dart';

/// Full-bleed fan art behind a screen's content, pre-blurred once here
/// rather than behind each glass card individually. [GlassSurface] cards
/// used to each carry their own `BackdropFilter`; with several of them
/// visible on one screen (Home has 7+) that meant 7+ live backdrop samples
/// re-composited every frame, which was enough to stall the renderer badly
/// on web (confirmed: taps stopped registering, not just slow paint). One
/// blur pass on the image itself gets the same "glassy" look at O(1) cost
/// instead of O(cards) — except for animated GIFs: [ImageFiltered] has to
/// re-run the blur every decoded frame, and doing that continuously for a
/// multi-hundred-frame GIF is what froze the renderer outright (confirmed:
/// `requestAnimationFrame` itself stopped firing on Rituals/Calendar/
/// Settings, not just a slow frame). GIFs stay sharp; [GlassSurface]'s
/// white wash + border still reads as glass without it.
class FanArtBackground extends StatelessWidget {
  const FanArtBackground({
    super.key,
    required this.assetPath,
    required this.child,
    this.tint,
  });

  final String assetPath;
  final Widget child;

  /// Optional low-alpha color wash (e.g. morning yellow vs. evening blue)
  /// layered between the photo and the content, for screens that used a
  /// mood gradient before this existed.
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(assetPath, fit: BoxFit.cover);
    final isAnimated = assetPath.toLowerCase().endsWith('.gif');
    return Stack(
      fit: StackFit.expand,
      children: [
        isAnimated
            ? image
            : ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                child: image,
              ),
        if (tint != null) ColoredBox(color: tint!),
        DefaultTextStyle.merge(
          style: const TextStyle(
            shadows: [
              Shadow(
                color: Colors.black45,
                blurRadius: 6,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: child,
        ),
      ],
    );
  }
}
