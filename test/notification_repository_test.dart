import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:daily_ruffian/features/notifications/data/notification_item.dart';
import 'package:daily_ruffian/features/notifications/data/notification_repository.dart';

void main() {
  late NotificationRepository repo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    repo = NotificationRepository(await SharedPreferences.getInstance());
  });

  test('starts empty with lastNotifiedStreak defaulting to 0', () {
    expect(repo.loadAll(), isEmpty);
    expect(repo.lastNotifiedStreak(), 0);
  });

  test('add persists a notification, newest first', () async {
    await repo.add(const NotificationItem(
      id: '1', avatarColorKey: 'pink', message: 'First', timestamp: '2026-07-17T08:00:00.000'));
    await repo.add(const NotificationItem(
      id: '2', avatarColorKey: 'blue', message: 'Second', timestamp: '2026-07-18T08:00:00.000'));

    final all = repo.loadAll();
    expect(all, hasLength(2));
    expect(all.first.id, '2'); // newest first
    expect(all.first.read, isFalse);
  });

  test('markAllRead flips every item to read', () async {
    await repo.add(const NotificationItem(
      id: '1', avatarColorKey: 'pink', message: 'Msg', timestamp: '2026-07-18T08:00:00.000'));

    await repo.markAllRead();

    expect(repo.loadAll().every((n) => n.read), isTrue);
  });

  test('clearAll empties the list', () async {
    await repo.add(const NotificationItem(
      id: '1', avatarColorKey: 'pink', message: 'Msg', timestamp: '2026-07-18T08:00:00.000'));

    await repo.clearAll();

    expect(repo.loadAll(), isEmpty);
  });

  test('setLastNotifiedStreak round-trips', () async {
    await repo.setLastNotifiedStreak(30);
    expect(repo.lastNotifiedStreak(), 30);
  });

  test('list is capped at 50 items, dropping the oldest', () async {
    for (var i = 0; i < 55; i++) {
      await repo.add(NotificationItem(
        id: '$i',
        avatarColorKey: 'pink',
        message: 'Msg $i',
        timestamp: '2026-07-${(i % 28 + 1).toString().padLeft(2, '0')}T08:00:00.000',
      ));
    }
    expect(repo.loadAll().length, lessThanOrEqualTo(50));
  });
}
