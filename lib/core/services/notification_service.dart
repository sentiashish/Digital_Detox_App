import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _plugin.initialize(settings);
  }

  Future<void> showSessionComplete({required int minutes}) async {
    const androidDetails = AndroidNotificationDetails(
      'focus_mode_sessions',
      'Focus sessions',
      channelDescription: 'Session updates and completion reminders',
      importance: Importance.high,
      priority: Priority.high,
    );
    await _plugin.show(
      1001,
      'Focus session complete',
      'You protected $minutes minutes. Nice work.',
      const NotificationDetails(android: androidDetails),
    );
  }
}
