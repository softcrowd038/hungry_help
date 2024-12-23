// ignore_for_file: avoid_print

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void backgroundNotificationResponseHandler(NotificationResponse notification) {
  print('Callback Handler Invoked: $notification');
  print('Callback Payload: ${notification.payload}');
}

class NotificationService {
  final FlutterLocalNotificationsPlugin notificationPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initNotification() async {
    const AndroidInitializationSettings initializationAndroidSettings =
        AndroidInitializationSettings('mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationAndroidSettings,
    );

    await notificationPlugin.initialize(
      initializationSettings,
      onDidReceiveBackgroundNotificationResponse:
          backgroundNotificationResponseHandler,
    );
  }

  Future<void> showNotification({
    int id = 0,
    String? title,
    String? body,
    String? payload,
  }) async {
    print('Showing notification: $id, $title, $body, $payload');
    await notificationPlugin.show(
      id,
      title,
      body,
      await notificationDetails(),
      payload: payload,
    );
  }

  Future<NotificationDetails> notificationDetails() async {
    return const NotificationDetails(
      iOS: DarwinNotificationDetails(),
      android: AndroidNotificationDetails(
        'channelId',
        'channelName',
        importance: Importance.max,
        priority: Priority.high,
      ),
    );
  }
}
