/// One entry in a greeting pack's manifest.json. The manifest is the single
/// source of truth for available clips — filenames are never hardcoded.
class AudioClip {
  const AudioClip({
    required this.id,
    required this.file,
    required this.tags,
    this.weight = 1,
  });

  final String id;
  final String file;
  final List<String> tags;

  /// Reserved for weighted random (rare/new clips). v1 ignores it.
  final int weight;

  factory AudioClip.fromJson(Map<String, dynamic> json) => AudioClip(
        id: json['id'] as String,
        file: json['file'] as String,
        tags: (json['tags'] as List<dynamic>? ?? const []).cast<String>(),
        weight: json['weight'] as int? ?? 1,
      );
}

class GreetingPack {
  const GreetingPack({
    required this.packId,
    required this.packName,
    required this.clips,
  });

  final String packId;
  final String packName;
  final List<AudioClip> clips;

  factory GreetingPack.fromJson(Map<String, dynamic> json) => GreetingPack(
        packId: json['pack_id'] as String,
        packName: json['pack_name'] as String? ?? '',
        clips: (json['clips'] as List<dynamic>? ?? const [])
            .map((c) => AudioClip.fromJson(c as Map<String, dynamic>))
            .toList(),
      );

  String assetPathFor(AudioClip clip) =>
      'assets/audio/greetings/$packId/${clip.file}';
}
