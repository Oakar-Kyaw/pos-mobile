import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class AppLocalNotification {
  static final notificationPlugin = FlutterLocalNotificationsPlugin();
  static Future<void> initialize() async {
    await requestNotification();

    //for android
    const initSettingsAndroid = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // for iOS
    const initSettingsIos = DarwinInitializationSettings();
    // for both platforms
    const initSettings = InitializationSettings(
      android: initSettingsAndroid,
      iOS: initSettingsIos,
    );
    // initialize the plugin with the settings
    await notificationPlugin.initialize(settings: initSettings);
    // Added notification channel creation (required for Android 8.0+)
    await createNotificationChannel();
  }

  // notification channel creation (required for Android 8.0+)
  static Future<void> createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'channelId',
      'channelName',
      description: 'notification',
      importance: Importance.max,
      playSound: true, // Added sound option
    );

    await notificationPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  /// Show notification with title and body
  Future<void> showNotification({
    required int notiId,
    required String title,
    required String body,
    required String imageUrl,
    required bool isAndroidImage,
    required bool isIOSImage,
  }) async {
    await notificationPlugin.show(
      id: notiId,
      title: title,
      body: body,
      notificationDetails: await notificationDetails(
        imageUrl: imageUrl,
        isAndroidImage: isAndroidImage,
        isIOSImage: isIOSImage,
      ),
    );
  }

  static Future<void> requestNotification() async {
    await notificationPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    // for iOS
    await notificationPlugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  /// Notification details for Android and iOS
  Future<NotificationDetails> notificationDetails({
    required String imageUrl,
    bool isAndroidImage = false,
    bool isIOSImage = false,
  }) async {
    // Android: large icon (round)
    ByteArrayAndroidBitmap? largeIcon;
    final androidImageUrl = isAndroidImage ? imageUrl : null;
    if (androidImageUrl != null && androidImageUrl.isNotEmpty) {
      try {
        final byteData = await NetworkAssetBundle(
          Uri.parse(androidImageUrl),
        ).load(androidImageUrl);
        final bytes = byteData.buffer.asUint8List();
        largeIcon = ByteArrayAndroidBitmap.fromBase64String(
          base64Encode(bytes),
        );
      } catch (e) {
        print("⚠️ Failed to load Android large icon: $e");
      }
    }

    // iOS: attachment (image)
    List<DarwinNotificationAttachment> iosAttachments = [];
    final iosImageUrl = isIOSImage ? imageUrl : null;
    if (iosImageUrl != null && iosImageUrl.isNotEmpty) {
      try {
        final byteData = await NetworkAssetBundle(
          Uri.parse(iosImageUrl),
        ).load(iosImageUrl);
        final bytes = byteData.buffer.asUint8List();
        final tempPath = "/tmp/ios_noti_image.png";
        final file = File(tempPath)..writeAsBytesSync(bytes);
        iosAttachments.add(DarwinNotificationAttachment(tempPath));
      } catch (e) {
        print("⚠️ Failed to load iOS attachment: $e");
      }
    }
    return NotificationDetails(
      android: AndroidNotificationDetails(
        'channelId',
        'channelName',
        channelDescription: 'notification',
        importance: Importance.max,
        priority: Priority.high,
        styleInformation: BigTextStyleInformation(''),
        largeIcon: largeIcon,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        attachments: iosAttachments,
      ),
    );
  }
}
