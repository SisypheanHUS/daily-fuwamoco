import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/local_date.dart';

/// A wallpaper entry. v1 ships gradients; `image` is already in the schema so
/// real artwork lands with a manifest edit, not a code change.
class Wallpaper {
  const Wallpaper({required this.id, this.colors = const [], this.image});

  final String id;
  final List<Color> colors;
  final String? image;

  factory Wallpaper.fromJson(Map<String, dynamic> json) => Wallpaper(
        id: json['id'] as String,
        image: json['image'] as String?,
        colors: (json['colors'] as List<dynamic>? ?? const [])
            .map((hex) => _parseHex(hex as String))
            .toList(),
      );

  static Color _parseHex(String hex) =>
      Color(int.parse(hex.replaceFirst('#', '0xFF')));
}

/// Deterministic per day, offset so quote and wallpaper don't rotate in
/// lockstep when the pools happen to be the same size.
class WallpaperRepository {
  const WallpaperRepository({this.bundle});

  final AssetBundle? bundle;

  Future<List<Wallpaper>> loadAll() async {
    try {
      final raw = await (bundle ?? rootBundle)
          .loadString('assets/wallpapers/manifest.json');
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return (json['wallpapers'] as List<dynamic>)
          .map((w) => Wallpaper.fromJson(w as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  static Wallpaper? wallpaperOfTheDay(List<Wallpaper> all, String dateKey) {
    if (all.isEmpty) return null;
    return all[stableHash('wp:$dateKey') % all.length];
  }
}

final wallpaperOfTheDayProvider = FutureProvider<Wallpaper?>((ref) async {
  final all = await const WallpaperRepository().loadAll();
  return WallpaperRepository.wallpaperOfTheDay(
      all, localDateKey(DateTime.now()));
});
