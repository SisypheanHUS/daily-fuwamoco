import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../data/notification_item.dart';
import '../data/notification_repository.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>(
  (ref) => NotificationRepository(ref.watch(sharedPreferencesProvider)),
);

class NotificationsController extends Notifier<List<NotificationItem>> {
  @override
  List<NotificationItem> build() =>
      ref.watch(notificationRepositoryProvider).loadAll();

  Future<void> markAllRead() async {
    final repo = ref.read(notificationRepositoryProvider);
    await repo.markAllRead();
    state = repo.loadAll();
  }

  Future<void> clearAll() async {
    final repo = ref.read(notificationRepositoryProvider);
    await repo.clearAll();
    state = repo.loadAll();
  }
}

final notificationsProvider =
    NotifierProvider<NotificationsController, List<NotificationItem>>(
      NotificationsController.new,
    );

/// Drives Home's bell badge — a single dot, never a numeric count (PRD-style
/// rule carried over from the mockup's own design note).
final hasUnreadNotificationsProvider = Provider<bool>(
  (ref) => ref.watch(notificationsProvider).any((n) => !n.read),
);
