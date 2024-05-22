import 'dart:async';
import 'dart:io';

import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

Future<void> initializeNotifications() async {
  // Initialize notification settings
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings =
  InitializationSettings(android: initializationSettingsAndroid);

  // Initialize notification plugin
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}




void main() {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();

  initializeNotifications().then((_) {
    startServiceInPlatform();
    runApp(const MyApp());
  });
}

void startServiceInPlatform() async {
  if (Platform.isAndroid) {
    const MethodChannel methodChannel = MethodChannel("com.example.basics_back");

    String data = await methodChannel.invokeMethod("startService");

    debugPrint(data);
  }

  scheduleNotifications();

}



void scheduleNotifications() {
  final myCoordinates = Coordinates(30.16239231144667, 71.51478590556405);
  final params = CalculationMethod.karachi.getParameters();
  params.madhab = Madhab.hanafi;
  final prayerTimes = PrayerTimes.today(myCoordinates, params);

  String fajarStr = DateFormat('HHmm').format(prayerTimes.fajr);
  int fajarHour = int.parse(fajarStr.substring(0, 2));
  int fajarMinute = int.parse(fajarStr.substring(2, 4));

  String duhrTimeStr = DateFormat('HHmm').format(prayerTimes.dhuhr);
  int duhrHour = int.parse(duhrTimeStr.substring(0, 2));
  int duhrMinute = int.parse(duhrTimeStr.substring(2, 4));

  String asrTimeStr = DateFormat('HHmm').format(prayerTimes.asr);
  int asrHour = int.parse(asrTimeStr.substring(0, 2));
  int asrMinute = int.parse(asrTimeStr.substring(2, 4));

  String magribStr = DateFormat('HHmm').format(prayerTimes.maghrib);
  int magribHour = int.parse(magribStr.substring(0, 2));
  int magribMinute = int.parse(magribStr.substring(2, 4));

  String ishaStr = DateFormat('HHmm').format(prayerTimes.isha);
  int ishaHour = int.parse(ishaStr.substring(0, 2));
  int ishaMinute = int.parse(ishaStr.substring(2, 4));

  final fajarTime = DateTime(DateTime.now().year, DateTime.now().month,
      DateTime.now().day, fajarHour, fajarMinute);
  final duhrTime = DateTime(DateTime.now().year, DateTime.now().month,
      DateTime.now().day, duhrHour, duhrMinute);
  final asrTime = DateTime(DateTime.now().year, DateTime.now().month,
      DateTime.now().day, asrHour, asrMinute);
  final magribTime = DateTime(DateTime.now().year, DateTime.now().month,
      DateTime.now().day, magribHour, magribMinute);
  final ishaTime = DateTime(DateTime.now().year, DateTime.now().month,
      DateTime.now().day, ishaHour, ishaMinute);


  print("This is Fajar Time: ${fajarTime}");
  print("This is Duhr Time: ${duhrTime}");
  print("This is Asr Time: ${asrTime}");
  print("This is Magrib Time: ${magribTime}");
  print("This is Isha Time: ${ishaTime}");


  final times = [
    fajarTime,
    duhrTime,
    asrTime,
    magribTime,
    ishaTime,
  ];

  for (int i = 0; i < times.length; i++) {
    scheduleNotification(i, times[i]);
  }
}


Future<void> scheduleNotification(int id, DateTime time) async {
  var scheduledTZTime = tz.TZDateTime.from(time, tz.local);

  print("Scheduling notification for: $scheduledTZTime");

  // Define notification details
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
  AndroidNotificationDetails(
    'your_channel_id', // channel ID
    'Channel Name', // channel name
    importance: Importance.max,
    priority: Priority.high,

  );
  const NotificationDetails platformChannelSpecifics =
  NotificationDetails(android: androidPlatformChannelSpecifics);

  // Schedule notification
  await flutterLocalNotificationsPlugin.zonedSchedule(
    id, // notification ID
    "Namaz", // title
    'Alarm', // body
    scheduledTZTime, // schedule time
    platformChannelSpecifics,
    androidAllowWhileIdle: true,
    uiLocalNotificationDateInterpretation:
    UILocalNotificationDateInterpretation.absoluteTime,
    matchDateTimeComponents: DateTimeComponents.time,
  );
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Background Services',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [
            Text("Services is running in background"),
          ],
        ),
      ),
    );
  }
}
