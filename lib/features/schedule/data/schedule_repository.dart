import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StreamEvent {
  const StreamEvent({required this.title, required this.start});

  final String title;
  final DateTime start;
}

/// v1 reads the stream schedule from a bundled JSON file (PRD §11.2).
/// Any failure or an empty upcoming list surfaces as null → UI shows "TBA".
class ScheduleRepository {
  const ScheduleRepository({this.bundle});

  final AssetBundle? bundle;

  Future<StreamEvent?> nextStream(DateTime now) async {
    try {
      final raw = await (bundle ?? rootBundle).loadString(
        'assets/schedule/schedule.json',
      );
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final events =
          (json['streams'] as List<dynamic>)
              .map(
                (s) => StreamEvent(
                  title: (s as Map<String, dynamic>)['title'] as String,
                  start: DateTime.parse(s['start'] as String).toLocal(),
                ),
              )
              .where((e) => e.start.isAfter(now))
              .toList()
            ..sort((a, b) => a.start.compareTo(b.start));
      return events.isEmpty ? null : events.first;
    } catch (_) {
      return null;
    }
  }
}

final nextStreamProvider = FutureProvider<StreamEvent?>(
  (ref) => const ScheduleRepository().nextStream(DateTime.now()),
);
