import 'package:flutter/material.dart';

import '../../features/content/data/wallpaper_repository.dart';

/// Full-bleed wallpaper. Gradients now, images later (same manifest schema).
/// Null wallpaper falls back to the theme surface — never a blank flash.
class WallpaperBackground extends StatelessWidget {
  const WallpaperBackground({super.key, this.wallpaper, required this.child});

  final Wallpaper? wallpaper;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final w = wallpaper;
    // SizedBox.expand: the background must cover the whole screen, not just
    // the intrinsic width of its content
    if (w == null || w.colors.length < 2) {
      return ColoredBox(
        color: Theme.of(context).colorScheme.surface,
        child: SizedBox.expand(child: child),
      );
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: w.colors,
        ),
      ),
      child: SizedBox.expand(child: child),
    );
  }
}
