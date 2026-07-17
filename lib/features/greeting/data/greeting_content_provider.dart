import 'dart:math';

import 'audio_clip.dart';
import 'greeting_context.dart';

/// Extension point for greeting selection (PRD §6.4). Future providers
/// (seasonal, birthday, weekend, voice packs) implement this interface and
/// join a priority chain — playback layer and state machine stay untouched.
abstract interface class GreetingContentProvider {
  List<AudioClip> getEligibleClips(GreetingContext context, List<AudioClip> all);
  AudioClip? pickOne(List<AudioClip> clips, {required bool random, Random? rng});
}

/// v1: tags must contain `generic`, uniform random. Ignores all other context.
class DefaultGreetingProvider implements GreetingContentProvider {
  const DefaultGreetingProvider();

  @override
  List<AudioClip> getEligibleClips(
    GreetingContext context,
    List<AudioClip> all,
  ) {
    return all.where((c) => c.tags.contains('generic')).toList();
  }

  @override
  AudioClip? pickOne(List<AudioClip> clips, {required bool random, Random? rng}) {
    if (clips.isEmpty) return null;
    if (!random) return clips.first;
    return clips[(rng ?? Random()).nextInt(clips.length)];
  }
}
