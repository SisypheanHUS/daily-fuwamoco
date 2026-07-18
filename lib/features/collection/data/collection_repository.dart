import 'dart:convert';

import 'package:flutter/services.dart';

import 'collection_item.dart';

class CollectionRepository {
  const CollectionRepository({this.bundle});

  final AssetBundle? bundle;

  Future<List<CollectionItem>> loadAll() async {
    try {
      final raw = await (bundle ?? rootBundle).loadString(
        'assets/collection/manifest.json',
      );
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return (json['items'] as List<dynamic>).map((i) {
        final map = i as Map<String, dynamic>;
        return CollectionItem(
          id: map['id'] as String,
          name: map['name'] as String,
          group: map['group'] as String,
          colorKey: map['colorKey'] as String,
          threshold: map['threshold'] as int?,
        );
      }).toList();
    } catch (_) {
      return const [];
    }
  }
}
