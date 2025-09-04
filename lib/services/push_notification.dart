import 'package:court_dairy/services/firebase_export.dart';
import 'package:flutter/foundation.dart';
import 'local_notification.dart';

class PushNotificationService {
  final FirebaseMessaging messaging = FirebaseMessaging.instance;

  static final LocalNotificationService localNotificationService =
      LocalNotificationService();

  Future<void> initialize() async {
    await requestPermission();
    // Listen for foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      if (message.data.isNotEmpty) {
        if (message.data['notiType'] == "call") {
          //do some work
        } else if (message.data['notiType'] == "chat") {
          await localNotificationService.showNotification(
              title: message.data['senderName'], body: message.data['message']);
        }
      }
    });

    // App opened from notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      if (message.data.isNotEmpty) {
        if (message.data['type'] == 'call') {
          //do some work
        } else {
          await localNotificationService.showNotification(
              title: 'Mahbub Hasan', body: 'This a is a local notification');
        }
      }
    });

    FirebaseMessaging.onBackgroundMessage(backgroundMessageHandler);
  }

  static Future<void> backgroundMessageHandler(RemoteMessage message) async {
    if (message.data.isNotEmpty) {
      if (message.data['notiType'] == 'call1') {
        //do some work
      } else {
        await localNotificationService.showNotification(
            title: 'Mahbub Hasan', body: 'This a is a local notification');
      }
    }
  }

  Future<void> requestPermission() async {
    try {
      NotificationSettings settings = await messaging.requestPermission();
      if (settings.authorizationStatus != AuthorizationStatus.authorized) {
        debugPrint('Notification permission denied');
      }
    } catch (e) {
      debugPrint('Error requesting permission: $e');
    }
  }
}
