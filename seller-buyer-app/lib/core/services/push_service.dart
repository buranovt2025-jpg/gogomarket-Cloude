import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../di/injection.dart';
import '../network/api_client.dart';

// Background handler — должен быть top-level функция
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('📲 BG push: ${message.notification?.title}');
}

class PushService {
  static final PushService instance = PushService._();
  factory PushService() => instance;
  PushService._();

  final _fcm = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // Request permission
    final settings = await _fcm.requestPermission(
      alert: true, badge: true, sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.denied) return;

    // Setup local notifications channel
    const androidChannel = AndroidNotificationChannel(
      'gogomarket_channel', 'GogoMarket',
      description: 'Уведомления GogoMarket',
      importance: Importance.high,
    );

    await _localNotifications
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(androidChannel);

    await _localNotifications.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
    );

    // Background handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Foreground handler
    FirebaseMessaging.onMessage.listen((msg) {
      final n = msg.notification;
      if (n == null) return;
      _localNotifications.show(
        msg.hashCode,
        n.title,
        n.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'gogomarket_channel', 'GogoMarket',
            icon: '@mipmap/ic_launcher',
            color: const Color(0xFFFF5001),
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        payload: jsonEncode(msg.data),
      );
    });

    // Save FCM token to backend
    final token = await _fcm.getToken();
    if (token != null) await _saveFcmToken(token);

    // Token refresh
    _fcm.onTokenRefresh.listen(_saveFcmToken);
  }

  Future<void> _saveFcmToken(String token) async {
    try {
      await getIt<ApiClient>().saveFcmToken(token);
      debugPrint('✅ FCM token saved: ${token.substring(0, 20)}...');
    } catch (e) {
      debugPrint('❌ FCM token save failed: $e');
    }
  }
}
