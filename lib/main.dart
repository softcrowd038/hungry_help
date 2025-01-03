import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:quick_social/Notifications/notifications_service.dart';
import 'package:quick_social/Notifications/task_performed.dart';
import 'package:quick_social/app.dart';
import 'package:quick_social/provider/closest_informer_provider.dart';
import 'package:quick_social/provider/donor_data_provider.dart';
import 'package:quick_social/provider/follow_status.dart';
import 'package:quick_social/provider/informer_data_provider.dart';
import 'package:quick_social/provider/like_status_provider.dart';
import 'package:quick_social/provider/live_location_provider.dart';
import 'package:quick_social/provider/post_provider.dart';
import 'package:quick_social/provider/profile_data_provider.dart';
import 'package:quick_social/provider/user_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }

  final NotificationService notificationService = NotificationService();
  await notificationService.initNotification();

 
  startNotificationLoop();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => UserProfileProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => DonorDataProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => InformerDataProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ClosestInformerProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => LocationProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => PostProvider(),
        ),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => FollowStatusProvider()),
        ChangeNotifierProvider(create: (_) => LikeStatusProvider()),
      ],
      child: const MyApp(),
    ),
  );
}
