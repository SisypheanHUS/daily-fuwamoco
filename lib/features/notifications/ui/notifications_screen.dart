import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/local_date.dart';
import '../../../shared/widgets/companion_mascot.dart';
import '../../../shared/widgets/section_label.dart';
import '../../habits/data/habit_colors.dart';
import '../data/notification_item.dart';
import '../logic/notification_providers.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    // Opening the inbox is what "reads" it — deferred a frame so the
    // still-unread tint is visible for at least the first paint.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(notificationsProvider.notifier).markAllRead();
    });
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (items.isNotEmpty)
            TextButton(
              onPressed: () => ref.read(notificationsProvider.notifier).clearAll(),
              child: const Text('Clear all'),
            ),
        ],
      ),
      body: items.isEmpty ? const _EmptyState() : _NotificationList(items: items),
    );
  }
}

class _NotificationList extends StatelessWidget {
  const _NotificationList({required this.items});

  final List<NotificationItem> items;

  @override
  Widget build(BuildContext context) {
    final todayKey = localDateKey(DateTime.now());
    final today = items.where((n) => n.timestamp.startsWith(todayKey)).toList();
    final earlier = items.where((n) => !n.timestamp.startsWith(todayKey)).toList();

    return ListView(
      padding: const EdgeInsets.all(Gap.md),
      children: [
        if (today.isNotEmpty) ...[
          const SectionLabel('Today'),
          const SizedBox(height: Gap.sm),
          for (final n in today) _NotificationRow(item: n),
          const SizedBox(height: Gap.md),
        ],
        if (earlier.isNotEmpty) ...[
          const SectionLabel('Earlier'),
          const SizedBox(height: Gap.sm),
          for (final n in earlier) _NotificationRow(item: n),
        ],
      ],
    );
  }
}

class _NotificationRow extends StatelessWidget {
  const _NotificationRow({required this.item});

  final NotificationItem item;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final timestamp = DateTime.tryParse(item.timestamp);
    return Container(
      margin: const EdgeInsets.only(bottom: Gap.sm),
      padding: const EdgeInsets.all(Gap.md),
      decoration: BoxDecoration(
        color: item.read ? Colors.transparent : AppTheme.cream,
        borderRadius: BorderRadius.circular(Corners.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CompanionMascot(size: 40, color: habitColor(item.avatarColorKey)),
          const SizedBox(width: Gap.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.message,
                    style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(
                  timestamp == null ? '' : _relativeTime(timestamp),
                  style: textTheme.bodySmall?.copyWith(color: AppTheme.inkFaint),
                ),
              ],
            ),
          ),
          if (!item.read)
            Container(
              width: 7,
              height: 7,
              margin: const EdgeInsets.only(top: 6, left: Gap.sm),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.pinkDeep,
              ),
            ),
        ],
      ),
    );
  }

  String _relativeTime(DateTime timestamp) {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    return DateFormat('MMM d').format(timestamp);
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Gap.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Static, not breathing — matches the mockup's dozing pose;
            // Notifications' empty state is meant to read as restful.
            const CompanionMascot(size: 88, color: AppTheme.blueDeep, sleepy: true, animate: false),
            const SizedBox(height: Gap.md),
            Text('All quiet',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: Gap.sm),
            Text(
              'No notifications right now — enjoy the quiet moment.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.inkSoft),
            ),
          ],
        ),
      ),
    );
  }
}
