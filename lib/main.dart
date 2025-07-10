import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_paymob/flutter_paymob.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mandm/data/themes_data.dart';
import 'package:mandm/pages/home_page.dart';
import 'package:mandm/pages/splash_page.dart';
import 'package:mandm/providers/home_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'data/local/AppDatabaseHelper.dart';
import 'data/local/cache_helper.dart';
import 'data/local/dbTablesHelpers/NotificationDb.dart';
import 'data/local/dbTablesHelpers/dbModels/db_models.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CacheHelper.init();
  await Firebase.initializeApp();
  final dbHelper = AppDatabaseHelper();
  await dbHelper.database;
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await FirebaseMessaging.instance.subscribeToTopic('wheely');
  const AndroidInitializationSettings androidSettings =
  AndroidInitializationSettings('@drawable/wheely_icon_notify_trans');
  const InitializationSettings initSettings =
  InitializationSettings(android: androidSettings);
  await flutterLocalNotificationsPlugin.initialize(
    initSettings,
    onDidReceiveNotificationResponse: (response) {
      final payload = response.payload;
      if (payload != null) {
        // Handle tap action
      }
    },
  );
  runApp(const App());
}

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();
    requestNotificationPermission();

    FirebaseMessaging.onMessage.listen((message) {
      if (message.data.isNotEmpty) {
        _showNotification(message);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      // Optional: Handle navigation
    });
  }
  Future<void> requestNotificationPermission() async {
    if (await Permission.notification.isDenied ||
        await Permission.notification.isPermanentlyDenied) {
      await Permission.notification.request();
    }
  }
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeProvider()), // Add HomeProvider
      ],
      child: GetMaterialApp(
        defaultTransition: Transition.rightToLeft,
        transitionDuration: const Duration(milliseconds: 500),
        debugShowCheckedModeBanner: false,
        title: 'Wheely',
        home: const SplashPage(),
        theme: lightModeTheme,
      ),
    );
  }
}


Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("XXXXX Background message: ${message.messageId}");
  _showNotification(message);
}

Future<void> requestNotificationPermission() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  if (Platform.isAndroid) {
    // Only needed on Android 13+
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted notification permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.denied) {
      print('User denied notification permission');
    } else {
      print('Notification permission not determined or restricted');
    }
  }
}

Future<void> requestNotificationPermissionManual() async {
  var status = await Permission.notification.status;
  if (!status.isGranted) {
    status = await Permission.notification.request();
    if (status.isGranted) {
      print('Notification permission granted');
    } else {
      print('Notification permission denied');
    }
  }
}

Future<void> _showNotification(RemoteMessage message) async {
  final data = message.data;
  final title = data['head'] ?? 'No Title';
  final body = data['desc'] ?? 'No Description';

  final notificationDb = NotificationDb();
  await notificationDb.insertItem(
    NotificationItem(
      // id: product.id,
      title: data['head'],
      description: data['desc'],
      action: '',
      topic: '',
    ),
  );

  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'fcm_data_channel',
    'Data Notifications',
    channelDescription: 'Channel for data-only FCM messages',
    importance: Importance.max,
    priority: Priority.high,
  );

  const NotificationDetails notificationDetails =
  NotificationDetails(android: androidDetails);

  await flutterLocalNotificationsPlugin.show(
    message.hashCode,
    title,
    body,
    notificationDetails,
    payload: data['url'], // you can handle it on tap
  );
}