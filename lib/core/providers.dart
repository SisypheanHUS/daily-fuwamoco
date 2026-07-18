import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('Overridden in main()'),
);

/// Settings' "Reset my data" calls this instead of clearing prefs directly —
/// individually invalidating every provider that reads SharedPreferences
/// would need updating every time a new feature adds one. [AppRoot] instead
/// overrides this to clear prefs and remount the whole `ProviderScope`,
/// which resets everything at once and can't silently miss a new provider.
final appResetProvider = Provider<Future<void> Function()>(
  (ref) => throw UnimplementedError('Overridden in AppRoot'),
);
