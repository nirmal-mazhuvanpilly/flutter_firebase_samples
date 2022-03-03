import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class CloudMessagingView extends StatefulWidget {
  const CloudMessagingView({Key? key}) : super(key: key);

  @override
  State<CloudMessagingView> createState() => _CloudMessagingViewState();
}

class _CloudMessagingViewState extends State<CloudMessagingView> {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  late NotificationSettings _settings;

  static const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id //The Same id should pass in the AndroidManifest.xml MetaData android.value
    'High Importance Notifications', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.max,
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  void _initilializeNotification() async {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    //Method to Request Notification
    await _requestNotification();

    await _onMessage();
    await _onMessageOpenedApp();
  }

  Future<void> _requestNotification() async {
    _settings = await _messaging.requestPermission();
    if (_settings.authorizationStatus == AuthorizationStatus.authorized) {
      // ignore: avoid_print
      print('User granted permission');
    } else if (_settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      // ignore: avoid_print
      print('User granted provisional permission');
    } else {
      // ignore: avoid_print
      print('User declined or has not accepted permission');
    }
  }

  Future<void> _onMessage() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      // ignore: avoid_print
      print('Got a message whilst in the foreground!');
      // ignore: avoid_print
      print('Message data: ${message.data}');

      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
                android: AndroidNotificationDetails(channel.id, channel.name,
                    importance: channel.importance,
                    channelDescription: channel.description,
                    icon:
                        "blueage_noti_icon") //The Same icon name should pass in the AndroidManifest.xml MetaData android.resource,
                ));
      }
    });
  }

  Future<void> _onMessageOpenedApp() async {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // ignore: avoid_print
      print('Got a message whilst in the foreground!');
      // ignore: avoid_print
      print('Message data: ${message.data}');

      if (message.notification != null) {
        // ignore: avoid_print
        print('Message also contained a notification');
      }
    });
  }

  @override
  void initState() {
    _initilializeNotification();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cloud Messaging"),
      ),
    );
  }
}
