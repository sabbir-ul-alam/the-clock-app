import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import 'logger_service.dart';

Future<void> ensureExactAlarmPermission(BuildContext context) async {
  final alarmStatus = await Permission.scheduleExactAlarm.status;
  // LoggerService.debug(alarmStatus.toString());
  if (alarmStatus != PermissionStatus.granted) {
    // Guard with a mounted check
    if (!context.mounted) return;

    final shouldRequest = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => PopScope(
              canPop: false, //  disables back button
              child: AlertDialog(
                title: const Text("Permission Required"),
                content: const Text(
                    "To ensure the alarms ring accurately at the correct time, you need to allow the permission on settings page"),
                actions: [
                  TextButton(
                      onPressed: () {
                        // Optionally close the app or disable functionality
                        SystemNavigator.pop(); // Uncomment to force close
                      },
                      child: const Text("Exit App")),
                  // TextButton(
                  //   onPressed: () => Navigator.pop(context, false),
                  //   child: const Text("Not Now"),
                  // ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text("Setting"),
                  ),
                ],
              ),
            ));

    if (shouldRequest == true) {
      await Permission.scheduleExactAlarm.request();
    }
  }

  // Now check notification permission (Android 13+)
  final notificationStatus = await Permission.notification.status;
  // LoggerService.debug('Notification Permission: $notificationStatus');

  if (!notificationStatus.isGranted) {
    if (!context.mounted) return;

    final shouldAsk = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Enable Notifications"),
        content: const Text(
            "To display alerts when your alarm rings, allow notification permission."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Later"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Allow"),
          ),
        ],
      ),
    );

    if (shouldAsk == true) {
      await Permission.notification.request();
    }
  }

}
