import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';

/// Audio priority order (PRD §7): muteAll > greetingEnabled > randomGreeting.
/// [audioAllowed] is the single place that encodes it.
class AppSettings {
  const AppSettings({
    required this.greetingEnabled,
    required this.greetingVolume,
    required this.randomGreeting,
    required this.muteAll,
    required this.reduceMotion,
    required this.displayName,
  });

  final bool greetingEnabled;
  final double greetingVolume; // 0.0–1.0
  final bool randomGreeting;
  final bool muteAll;
  final bool reduceMotion;
  final String displayName;

  bool get audioAllowed => !muteAll && greetingEnabled;

  AppSettings copyWith({
    bool? greetingEnabled,
    double? greetingVolume,
    bool? randomGreeting,
    bool? muteAll,
    bool? reduceMotion,
    String? displayName,
  }) =>
      AppSettings(
        greetingEnabled: greetingEnabled ?? this.greetingEnabled,
        greetingVolume: greetingVolume ?? this.greetingVolume,
        randomGreeting: randomGreeting ?? this.randomGreeting,
        muteAll: muteAll ?? this.muteAll,
        reduceMotion: reduceMotion ?? this.reduceMotion,
        displayName: displayName ?? this.displayName,
      );
}

class SettingsController extends Notifier<AppSettings> {
  static const kGreetingEnabled = 'settings_greeting_enabled';
  static const kGreetingVolume = 'settings_greeting_volume';
  static const kRandomGreeting = 'settings_random_greeting';
  static const kMuteAll = 'settings_mute_all';
  static const kReduceMotion = 'settings_reduce_motion';
  static const kDisplayName = 'settings_display_name';

  @override
  AppSettings build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return AppSettings(
      greetingEnabled: prefs.getBool(kGreetingEnabled) ?? true,
      greetingVolume: prefs.getDouble(kGreetingVolume) ?? 0.8,
      randomGreeting: prefs.getBool(kRandomGreeting) ?? true,
      muteAll: prefs.getBool(kMuteAll) ?? false,
      reduceMotion: prefs.getBool(kReduceMotion) ?? false,
      displayName: prefs.getString(kDisplayName) ?? '',
    );
  }

  void setGreetingEnabled(bool value) {
    ref.read(sharedPreferencesProvider).setBool(kGreetingEnabled, value);
    state = state.copyWith(greetingEnabled: value);
  }

  void setGreetingVolume(double value) {
    ref.read(sharedPreferencesProvider).setDouble(kGreetingVolume, value);
    state = state.copyWith(greetingVolume: value);
  }

  void setRandomGreeting(bool value) {
    ref.read(sharedPreferencesProvider).setBool(kRandomGreeting, value);
    state = state.copyWith(randomGreeting: value);
  }

  void setMuteAll(bool value) {
    ref.read(sharedPreferencesProvider).setBool(kMuteAll, value);
    state = state.copyWith(muteAll: value);
  }

  void setReduceMotion(bool value) {
    ref.read(sharedPreferencesProvider).setBool(kReduceMotion, value);
    state = state.copyWith(reduceMotion: value);
  }

  void setDisplayName(String value) {
    ref.read(sharedPreferencesProvider).setString(kDisplayName, value);
    state = state.copyWith(displayName: value);
  }
}

final settingsProvider =
    NotifierProvider<SettingsController, AppSettings>(SettingsController.new);
