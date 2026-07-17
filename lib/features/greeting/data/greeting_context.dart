/// Everything a content provider may want to know when picking a clip.
/// v1 only fills [date]; the rest are the anchors for seasonal / birthday /
/// weekend / weather providers on the roadmap (PRD §9) — do not use them yet.
class GreetingContext {
  const GreetingContext({
    required this.date,
    this.isWeekend = false,
    this.isHoliday = false,
    this.isBirthday = false,
    this.season,
    this.weather,
    this.userFavorites,
  });

  final DateTime date;
  final bool isWeekend;
  final bool isHoliday;
  final bool isBirthday;
  final String? season;
  final String? weather;
  final List<String>? userFavorites;
}
