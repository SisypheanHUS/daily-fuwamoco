import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/local_date.dart';

class Quote {
  const Quote({required this.id, required this.text});

  final String id;
  final String text;
}

/// Quote of the day is deterministic per calendar day (PRD §6.5):
/// same day → same quote, regardless of how often it's computed.
class QuoteRepository {
  const QuoteRepository({this.bundle});

  final AssetBundle? bundle;

  Future<List<Quote>> loadAll() async {
    try {
      final raw = await (bundle ?? rootBundle).loadString(
        'assets/quotes/quotes.json',
      );
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return (json['quotes'] as List<dynamic>)
          .map(
            (q) => Quote(
              id: (q as Map<String, dynamic>)['id'] as String,
              text: q['text'] as String,
            ),
          )
          .toList();
    } catch (_) {
      return const [];
    }
  }

  static Quote? quoteOfTheDay(List<Quote> quotes, String dateKey) {
    if (quotes.isEmpty) return null;
    return quotes[stableHash(dateKey) % quotes.length];
  }
}

final quoteOfTheDayProvider = FutureProvider<Quote?>((ref) async {
  final quotes = await const QuoteRepository().loadAll();
  return QuoteRepository.quoteOfTheDay(quotes, localDateKey(DateTime.now()));
});
