import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:daily_ruffian/core/utils/local_date.dart';
import 'package:daily_ruffian/features/content/data/quote_repository.dart';
import 'package:daily_ruffian/features/greeting/data/audio_clip.dart';
import 'package:daily_ruffian/features/greeting/data/greeting_content_provider.dart';
import 'package:daily_ruffian/features/greeting/data/greeting_context.dart';

void main() {
  group('quote of the day', () {
    final quotes = List.generate(
      14,
      (i) => Quote(id: 'q$i', text: 'quote $i'),
    );

    test('same day always returns the same quote', () {
      final a = QuoteRepository.quoteOfTheDay(quotes, '2026-07-17');
      final b = QuoteRepository.quoteOfTheDay(quotes, '2026-07-17');
      expect(a!.id, b!.id);
    });

    test('empty pool returns null instead of crashing', () {
      expect(QuoteRepository.quoteOfTheDay(const [], '2026-07-17'), isNull);
    });

    test('stableHash is deterministic', () {
      expect(stableHash('2026-07-17'), stableHash('2026-07-17'));
      expect(stableHash('a'), isNot(stableHash('b')));
    });
  });

  group('DefaultGreetingProvider', () {
    const provider = DefaultGreetingProvider();
    final context = GreetingContext(date: DateTime(2026, 7, 17));
    const clips = [
      AudioClip(id: 'a', file: 'a.wav', tags: ['generic']),
      AudioClip(id: 'b', file: 'b.wav', tags: ['seasonal:tet']),
      AudioClip(id: 'c', file: 'c.wav', tags: ['generic']),
    ];

    test('only generic clips are eligible in v1', () {
      final eligible = provider.getEligibleClips(context, clips);
      expect(eligible.map((c) => c.id), ['a', 'c']);
    });

    test('random off always picks the first clip', () {
      final eligible = provider.getEligibleClips(context, clips);
      expect(provider.pickOne(eligible, random: false)!.id, 'a');
    });

    test('random picks stay inside the eligible pool', () {
      final eligible = provider.getEligibleClips(context, clips);
      final rng = Random(42);
      for (var i = 0; i < 50; i++) {
        final picked = provider.pickOne(eligible, random: true, rng: rng);
        expect(['a', 'c'], contains(picked!.id));
      }
    });

    test('empty pool returns null (visual-only fallback)', () {
      expect(provider.pickOne(const [], random: true), isNull);
    });
  });
}
