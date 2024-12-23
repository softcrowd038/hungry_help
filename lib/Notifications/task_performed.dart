import 'package:workmanager/workmanager.dart';

void scheduleBackgroundTask() {
  print('entered periodic task');
  Workmanager().registerPeriodicTask(
    '1',
    'simpleTask',
    frequency: const Duration(minutes: 15), // Minimum time for periodic tasks
  );
}
