import 'dart:convert';

import 'package:flutter/services.dart';

import 'audio_clip.dart';

/// Loads a greeting pack's manifest from bundled assets.
/// A broken or missing manifest yields an empty pack — the visual sequence
/// must never be blocked by audio problems (PRD §8.3).
class GreetingPackRepository {
  const GreetingPackRepository({this.bundle});

  final AssetBundle? bundle;

  Future<GreetingPack> loadPack({String packId = 'default'}) async {
    try {
      final raw = await (bundle ?? rootBundle)
          .loadString('assets/audio/greetings/$packId/manifest.json');
      return GreetingPack.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return GreetingPack(packId: packId, packName: '', clips: const []);
    }
  }
}
