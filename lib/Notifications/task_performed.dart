import 'dart:async';

import 'package:quick_social/Notifications/notifications_service.dart';
import 'package:quick_social/data/notification_data.dart';

NotificationService notificationService = NotificationService();

void startNotificationLoop() {
  int i = 0;
  Timer.periodic(const Duration(minutes: 20), (timer) {
    final notification = notifications[i];
    notificationService.showNotification(
      id: i + 1,
      title: notification['title'],
      body: notification['body'],
      payload: 'Payload for notification ${i + 1}',
    );
    i = (i + 1) % notifications.length;
  });
}
