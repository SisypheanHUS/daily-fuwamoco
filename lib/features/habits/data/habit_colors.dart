import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// Small fixed palette a habit's icon color is picked from — a named key is
/// stored (not a raw Color) so it survives a future palette retune.
const habitColorSwatches = <String, Color>{
  'yellow': AppTheme.yellow,
  'blue': AppTheme.blue,
  'pink': AppTheme.pink,
  'cream': AppTheme.creamDeep,
  'blueDeep': AppTheme.blueDeep,
};

Color habitColor(String key) => habitColorSwatches[key] ?? AppTheme.cream;
