import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../data/daily_entry.dart';
import '../data/mood_colors.dart';

/// Five unlabeled colored circles — shared between Morning Check-in and
/// Evening Reflection so the interaction (and the mood palette) reads the
/// same both times.
class MoodPicker extends StatelessWidget {
  const MoodPicker({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final Mood? selected;
  final ValueChanged<Mood> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (final mood in Mood.values)
          GestureDetector(
            onTap: () => onChanged(mood),
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: moodColors[mood],
                border: selected == mood
                    ? Border.all(color: AppTheme.yellowDeep, width: 3)
                    : null,
              ),
            ),
          ),
      ],
    );
  }
}
