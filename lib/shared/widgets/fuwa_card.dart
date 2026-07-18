import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'glass_surface.dart';

/// Rounded glass surface — the app's one card shape. Every screen sits on a
/// full-bleed [FanArtBackground] photo/gif; [GlassSurface] keeps the picture
/// readable through it (blurred, faint white wash, bright edge) instead of
/// either hiding it under a solid fill or leaving text to float bare.
class FuwaCard extends StatelessWidget {
  const FuwaCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(Gap.md),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => GlassSurface(
    radius: Corners.md,
    padding: padding,
    width: double.infinity,
    child: child,
  );
}
