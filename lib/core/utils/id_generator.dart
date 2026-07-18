/// Local-only, single-user ID generation — no `uuid` dependency needed.
/// Microsecond timestamps are unique enough for data one person creates by
/// hand (habits, notifications), one at a time.
String generateLocalId() => DateTime.now().microsecondsSinceEpoch.toString();
