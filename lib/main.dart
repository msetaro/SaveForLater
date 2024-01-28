import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:save_for_later/home_page.dart';
import 'package:save_for_later/util/notification_controller.dart';
import 'package:save_for_later/util/tile_model.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(TileModelAdapter());
  await Hive.openBox("mybox");

  await AwesomeNotifications().initialize(
    null, //TODO: Change to icon path
    [ NotificationChannel(
      channelGroupKey: "main_channel_group",
      channelKey: 'main_channel', 
      channelName: 'Main Channel', 
      channelDescription: "Reminder to purchase an item"
    )],
    channelGroups: [
      NotificationChannelGroup(channelGroupKey: "main_channel_group", channelGroupName: "Main Group")
    ]
  );

  bool hasPermissions = await AwesomeNotifications().isNotificationAllowed();

  if (!hasPermissions)
  {
    AwesomeNotifications().requestPermissionToSendNotifications();
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    AwesomeNotifications().setListeners(
        onActionReceivedMethod: NotificationController.onActionReceivedMethod,
        onNotificationCreatedMethod: NotificationController.onNotificationCreatedMethod,
        onNotificationDisplayedMethod: NotificationController.onNotificationDisplayedMethod,
        onDismissActionReceivedMethod: NotificationController.onDismissActionReceivedMethod,
    );
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 150, 20, 11)),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}