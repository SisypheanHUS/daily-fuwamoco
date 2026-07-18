import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Rounded surface container — the app's one card shape, generalized out of
/// Home's original private `_Card` now that Habit Tracker/Collection/
/// Notifications need the same thing.
class FuwaCard extends StatelessWidget {
  const FuwaCard({
    super.key,
    required this.child,
    this.color,
    this.padding = const EdgeInsets.all(Gap.md),
  });

  final Widget child;
  final Color? color;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: padding,
        decoration: BoxDecoration(
          color: color ?? Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(Corners.md),
        ),
        child: child,
      );
}
