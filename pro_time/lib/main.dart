import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';
import 'package:pro_time/resources/activity_adapter.dart';
import 'package:pro_time/resources/application_state.dart';
import 'package:pro_time/resources/projects_adapter.dart';
import 'package:pro_time/resources/subactivity_adapter.dart';
import 'package:pro_time/ui/home.dart';
import 'package:provider/provider.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

void main() async {
  Hive.registerAdapter(ProjectsAdapter(), 35);
  Hive.registerAdapter(ActivityAdapter(), 36);
  Hive.registerAdapter(SubActivityAdapter(), 37);
  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  var initializationSettingsAndroid =
      AndroidInitializationSettings('ic_notification');
  var initializationSettingsIOS = IOSInitializationSettings();
  var initializationSettings = InitializationSettings(
      initializationSettingsAndroid, initializationSettingsIOS);
  flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: onSelectNotification);
  runApp(ProTime());
}

Future onSelectNotification(String id) async {}

enum TimerState { STOPPED, STARTED, PAUSED }

class ProTime extends StatelessWidget {
  static final navigatorKey = new GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return Provider<ApplicationState>.value(
      value: ApplicationState(),
      child: MaterialApp(
        title: 'ProTime',
        navigatorKey: navigatorKey,
        theme: ThemeData(
          fontFamily: 'Cereal',
          primarySwatch: Colors.grey,
        ),
        home: HomePage(),
      ),
    );
  }
}
