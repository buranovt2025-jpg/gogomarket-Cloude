import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('[Push] Background: ${message.notification?.title}');
}

class PushService {
  static final FlutterLocalNotificationsPlugin _localNotifs =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    // Канал для Android
    const channel = AndroidNotificationChannel(
      'gogomarket_orders',
      'GogoMarket',
      description: 'Уведомления о заказах и акциях',
      importance: Importance.high,
    );
    await _localNotifs
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Инициализация плагина
    await _localNotifs.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );

    // Фоновый обработчик
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Запрос разрешения
    final messaging = FirebaseMessaging.instance;
    final settings = await messaging.requestPermission(
      alert: true, badge: true, sound: true,
    );
    debugPrint('[Push] Permission: ${settings.authorizationStatus}');

    // Получаем FCM токен
    final token = await messaging.getToken();
    debugPrint('[Push] FCM Token: $token');

    // Обновляем токен на сервере при обновлении
    messaging.onTokenRefresh.listen(_sendTokenToServer);
    if (token != null) _sendTokenToServer(token);

    // Foreground сообщения
    FirebaseMessaging.onMessage.listen((message) {
      final notif = message.notification;
      if (notif == null) return;
      _localNotifs.show(
        notif.hashCode,
        notif.title,
        notif.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'gogomarket_orders',
            'GogoMarket',
            channelDescription: 'Уведомления о заказах',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
      );
    });
  }

  static void _sendTokenToServer(String token) {
    // TODO: POST /api/users/fcm-token   (после авторизации)
    debugPrint('[Push] Sending token to server: ${token.substring(0, 20)}...');
  }
}
