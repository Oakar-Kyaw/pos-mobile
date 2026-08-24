import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:pos/core/widgets/app-local-notification.dart';

class NotificationMessage {
  final String title;
  final String description;
  final String imageUrl;
  final bool isAndroidImage;
  final bool isIOSImage;
  NotificationMessage({
    required this.title,
    required this.description,
    required this.imageUrl,
    this.isAndroidImage = false,
    this.isIOSImage = false,
  });
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("📥 Background message received: ${message.data}");
  final backgroundData = message.data;
  if (backgroundData["title"].isEmpty && backgroundData["body"].isEmpty) {
    debugPrint("⚠️ Empty notification payload, skipping");
    return;
  }
  NotificationMessage msg = NotificationMessage(
    title: backgroundData["title"] ?? "",
    description: backgroundData["body"] ?? "",
    imageUrl: backgroundData["imageUrl"] ?? "",
    isAndroidImage: Platform.isAndroid,
    isIOSImage: Platform.isIOS,
  );
  try {
    AppLocalNotification().showNotification(
      notiId: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title: msg.title,
      body: msg.description,
      imageUrl: msg.imageUrl,
      isAndroidImage: msg.isAndroidImage,
      isIOSImage: msg.isIOSImage,
    );
    // final storage = NotificationStorage();
    // final count = await storage.getNotificationBellNumber();
    // await storage.saveNotificationBellTotalNumber(numb: count + 1);

    // debugPrint("🔔 Background count: $count → ${count + 1}");
  } catch (e, s) {
    debugPrint("❌ Background handler error: $e");
    debugPrint("$s");
  }
}

class FirebaseService {
  FirebaseService.internal();
  static final FirebaseService instance = FirebaseService.internal();
  bool _initialized = false;
  Future<void> init() async {
    if (_initialized) return;
    await Firebase.initializeApp();
    _initialized = true;
  }

  Stream<NotificationMessage> noitificationListen() {
    return FirebaseMessaging.onMessage.map((message) {
      String imageUrl = "";
      bool isAndroidImage = false;
      bool isIOSImage = false;
      // print(
      //   "📩 Notification: ${message.notification?.title} - ${message.notification?.body}",
      // );
      // print("📦 Data: ${message.data}");
      // print("🆔 Message ID: ${message.messageId}");

      if (Platform.isAndroid &&
          message.notification?.android?.imageUrl != null) {
        imageUrl = message.notification!.android!.imageUrl!;
        isAndroidImage = true;
      } else if (Platform.isIOS && message.data["imageUrl"] != null) {
        imageUrl = message.data["imageUrl"]!;
        isIOSImage = true;
      }
      return NotificationMessage(
        title: message.notification?.title ?? "",
        description: message.notification?.body ?? "",
        imageUrl: imageUrl,
        isAndroidImage: isAndroidImage,
        isIOSImage: isIOSImage,
      );
    });
  }
}
