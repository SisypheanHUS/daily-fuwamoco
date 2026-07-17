import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import '../data/audio_clip.dart';

/// Plays a greeting clip from bundled assets. Every failure path is silent:
/// audio must never crash or block the visual sequence (PRD §8.3, AC 5).
class GreetingAudioService {
  GreetingAudioService();

  AudioPlayer? _player;

  Future<void> play(GreetingPack pack, AudioClip clip,
      {required double volume}) async {
    try {
      await _player?.dispose();
      final player = AudioPlayer();
      _player = player;
      await player.setAsset(pack.assetPathFor(clip));
      await player.setVolume(volume.clamp(0.0, 1.0));
      // fire and forget — the animation does not wait for playback, and a
      // playback error (e.g. web autoplay policy) must stay silent too
      unawaited(player.play().catchError((Object e) {
        debugPrint('Greeting audio playback failed (silent fallback): $e');
      }));
    } catch (e) {
      debugPrint('Greeting audio failed (silent fallback): $e');
    }
  }

  Future<void> dispose() async {
    await _player?.dispose();
    _player = null;
  }
}
