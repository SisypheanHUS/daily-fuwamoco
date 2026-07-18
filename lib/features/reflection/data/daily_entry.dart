/// Five colored mood options, matching the mockup's unlabeled circle picker —
/// names are just enough to store/compare, not shown as text anywhere.
enum Mood { calm, neutral, happy, tender, warm }

/// One record per calendar day, covering both the Morning Check-in and
/// Evening Reflection flows. A day starts with neither half filled in;
/// each half is independently completable (morning can be done without
/// evening yet, and vice versa on an unusual day).
class DailyEntry {
  const DailyEntry({
    required this.dateKey,
    this.morningMood,
    this.morningNote,
    this.morningCompletedAt,
    this.eveningMood,
    this.eveningGoodThing,
    this.eveningCompletedAt,
  });

  final String dateKey;
  final Mood? morningMood;
  final String? morningNote;
  final String? morningCompletedAt;
  final Mood? eveningMood;
  final String? eveningGoodThing;
  final String? eveningCompletedAt;

  bool get morningDone => morningCompletedAt != null;
  bool get eveningDone => eveningCompletedAt != null;

  DailyEntry copyWith({
    Mood? morningMood,
    String? morningNote,
    String? morningCompletedAt,
    Mood? eveningMood,
    String? eveningGoodThing,
    String? eveningCompletedAt,
  }) => DailyEntry(
    dateKey: dateKey,
    morningMood: morningMood ?? this.morningMood,
    morningNote: morningNote ?? this.morningNote,
    morningCompletedAt: morningCompletedAt ?? this.morningCompletedAt,
    eveningMood: eveningMood ?? this.eveningMood,
    eveningGoodThing: eveningGoodThing ?? this.eveningGoodThing,
    eveningCompletedAt: eveningCompletedAt ?? this.eveningCompletedAt,
  );

  Map<String, dynamic> toJson() => {
    'dateKey': dateKey,
    'morningMood': morningMood?.name,
    'morningNote': morningNote,
    'morningCompletedAt': morningCompletedAt,
    'eveningMood': eveningMood?.name,
    'eveningGoodThing': eveningGoodThing,
    'eveningCompletedAt': eveningCompletedAt,
  };

  factory DailyEntry.fromJson(Map<String, dynamic> json) => DailyEntry(
    dateKey: json['dateKey'] as String,
    morningMood: _moodFromName(json['morningMood'] as String?),
    morningNote: json['morningNote'] as String?,
    morningCompletedAt: json['morningCompletedAt'] as String?,
    eveningMood: _moodFromName(json['eveningMood'] as String?),
    eveningGoodThing: json['eveningGoodThing'] as String?,
    eveningCompletedAt: json['eveningCompletedAt'] as String?,
  );

  static Mood? _moodFromName(String? name) {
    if (name == null) return null;
    for (final m in Mood.values) {
      if (m.name == name) return m;
    }
    return null;
  }
}
