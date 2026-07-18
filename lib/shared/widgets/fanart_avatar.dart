import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// An AppBar leading icon showing one of the bundled fan art images —
/// [Gap.xs] padding + a circular crop, the same wrapper every screen using
/// one otherwise re-types.
class FanArtLeading extends StatelessWidget {
  const FanArtLeading(this.assetPath, {super.key});

  final String assetPath;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(Gap.xs),
        child: ClipOval(child: Image.asset(assetPath, fit: BoxFit.cover)),
      );
}
