enum HabitTimeOfDay { morning, anytime, evening }

/// A user-defined recurring ritual (the "Rituals" tab) — distinct from the
/// two fixed daily flows (Morning Check-in / Evening Reflection) shown on
/// Home. Completion history is denormalized onto the habit itself
/// (`completedDateKeys`) rather than a separate join table — at this scale
/// (one person, a handful of habits) that's simpler to reason about and
/// query than normalizing it out.
class Habit {
  const Habit({
    required this.id,
    required this.title,
    required this.timeOfDay,
    required this.colorKey,
    this.completedDateKeys = const {},
  });

  final String id;
  final String title;
  final HabitTimeOfDay timeOfDay;
  final String colorKey;
  final Set<String> completedDateKeys;

  bool isDoneOn(String dateKey) => completedDateKeys.contains(dateKey);

  Habit copyWith({Set<String>? completedDateKeys}) => Habit(
    id: id,
    title: title,
    timeOfDay: timeOfDay,
    colorKey: colorKey,
    completedDateKeys: completedDateKeys ?? this.completedDateKeys,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'timeOfDay': timeOfDay.name,
    'colorKey': colorKey,
    'completedDateKeys': completedDateKeys.toList(),
  };

  factory Habit.fromJson(Map<String, dynamic> json) => Habit(
    id: json['id'] as String,
    title: json['title'] as String,
    timeOfDay: HabitTimeOfDay.values.firstWhere(
      (t) => t.name == json['timeOfDay'],
      orElse: () => HabitTimeOfDay.anytime,
    ),
    colorKey: json['colorKey'] as String? ?? 'cream',
    completedDateKeys:
        ((json['completedDateKeys'] as List<dynamic>?) ?? const [])
            .cast<String>()
            .toSet(),
  );
}
