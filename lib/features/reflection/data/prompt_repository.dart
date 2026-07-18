import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Suggestion chips for "one thing I'm looking forward to" — manifest-driven
/// like every other piece of bundled content in this app, not hardcoded
/// strings in the widget.
class PromptRepository {
  const PromptRepository({this.bundle});

  final AssetBundle? bundle;

  Future<List<String>> loadingForwardChips() async {
    try {
      final raw = await (bundle ?? rootBundle)
          .loadString('assets/prompts/looking_forward_chips.json');
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return (json['chips'] as List<dynamic>).cast<String>();
    } catch (_) {
      return const [];
    }
  }
}

final lookingForwardChipsProvider = FutureProvider<List<String>>(
  (ref) => const PromptRepository().loadingForwardChips(),
);
