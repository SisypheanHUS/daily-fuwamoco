import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Shared primitive for the first kind of data this app persists that isn't
/// a flat setting or a read-only bundled manifest: small, user-generated,
/// mutable lists (habits, notifications, daily check-in entries). Every
/// consumer gets the same fail-safe behavior as the asset repositories —
/// corrupt/missing data yields an empty list, never a crash.
List<Map<String, dynamic>> readJsonList(SharedPreferences prefs, String key) {
  final raw = prefs.getString(key);
  if (raw == null) return const [];
  try {
    return (jsonDecode(raw) as List<dynamic>).cast<Map<String, dynamic>>();
  } catch (_) {
    return const [];
  }
}

Future<void> writeJsonList(
  SharedPreferences prefs,
  String key,
  List<Map<String, dynamic>> items,
) => prefs.setString(key, jsonEncode(items));
