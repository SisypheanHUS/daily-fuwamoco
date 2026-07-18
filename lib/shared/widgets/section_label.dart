import 'package:flutter/material.dart';

import 'glass_surface.dart';

/// Small uppercase group header — "MORNING", "QUOTE OF THE DAY", etc. Sits
/// in a small glass pill: most call sites are group headers directly on a
/// screen's [FanArtBackground] photo, outside any [FuwaCard].
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GlassSurface(
      radius: 8,
      tintOpacity: 0.22,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      child: Text(
        text.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: scheme.onSurfaceVariant,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
