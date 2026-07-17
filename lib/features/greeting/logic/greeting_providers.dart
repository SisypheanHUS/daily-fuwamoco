import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app.dart';
import '../data/greeting_content_provider.dart';
import '../data/greeting_pack_repository.dart';
import '../data/audio_clip.dart';
import 'greeting_audio.dart';
import 'greeting_gate.dart';

final greetingGateProvider = Provider<GreetingGate>(
  (ref) => GreetingGate(ref.watch(sharedPreferencesProvider)),
);

final greetingPackProvider = FutureProvider<GreetingPack>(
  (ref) => const GreetingPackRepository().loadPack(),
);

/// v1 chain is just the default provider. Roadmap providers are prepended
/// here (birthday > seasonal > weekend > default) without touching callers.
final greetingContentProvider = Provider<GreetingContentProvider>(
  (ref) => const DefaultGreetingProvider(),
);

final greetingAudioProvider = Provider<GreetingAudioService>((ref) {
  final service = GreetingAudioService();
  ref.onDispose(service.dispose);
  return service;
});
