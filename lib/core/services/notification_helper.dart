import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();
    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );
    await _notificationsPlugin.initialize(initializationSettings);
    await requestPermission();
  }
  static Future<void> requestPermission() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }
  static Future<void> showPriceAlertNotification(
    String symbol,
    double targetPrice,
    double currentPrice,
    bool isAbove,
  ) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'tideview_price_alerts',
          'Price Alerts',
          channelDescription: 'Notifikasi saat harga menyentuh target',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker',
          color: Colors.deepPurple,
        );
    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );
    final direction = isAbove ? 'naik menembus' : 'turun menyentuh';
    final title =
        '🚨 Alert: $symbol $direction \$${targetPrice.toStringAsFixed(2)}!';
    final body =
        'Harga $symbol saat ini \$${currentPrice.toStringAsFixed(2)}. Cek portofolio lu sekarang!';
    final notifId = symbol.hashCode;
    await _notificationsPlugin.show(notifId, title, body, platformDetails);
  }
}
