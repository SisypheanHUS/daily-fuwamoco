/// v1's only trigger is a streak milestone (7/30/100 days) — see
/// `milestone_trigger.dart`. Scheduled reminder-style notifications need
/// real OS scheduling (`flutter_local_notifications` + platform permission
/// setup), deliberately deferred; this is an in-app inbox only.
class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.avatarColorKey,
    required this.message,
    required this.timestamp,
    this.read = false,
  });

  final String id;
  final String avatarColorKey;
  final String message;
  final String timestamp; // ISO8601
  final bool read;

  NotificationItem copyWith({bool? read}) => NotificationItem(
        id: id,
        avatarColorKey: avatarColorKey,
        message: message,
        timestamp: timestamp,
        read: read ?? this.read,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'avatarColorKey': avatarColorKey,
        'message': message,
        'timestamp': timestamp,
        'read': read,
      };

  factory NotificationItem.fromJson(Map<String, dynamic> json) => NotificationItem(
        id: json['id'] as String,
        avatarColorKey: json['avatarColorKey'] as String? ?? 'blue',
        message: json['message'] as String,
        timestamp: json['timestamp'] as String,
        read: json['read'] as bool? ?? false,
      );
}
