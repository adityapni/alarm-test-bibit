import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:test_clock/wakeup_chart.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'flutter_analog_clock.dart';
import 'notification_service.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  Widget homepage = MyHomePage(title: 'Alarm App',);
  // Widget homepage = WakeupChart();

  onSelectNotification(String? payload) async {
    if (payload != null) {
      print('notification payload: $payload');
    }
    // setState(() {
    //   homepage = WakeupChart();
    // });
    navKey.currentState!.push( MaterialPageRoute(builder: (context) => WakeupChart() ));

  }

  bool didNotificationLaunchApp = false;

  initNotificationService() async {
    await NotificationService().init(onSelectNotification); //
    await NotificationService().requestIOSPermissions(); //
    didNotificationLaunchApp = await NotificationService().didNotificationLaunchApp;
    print('didNotificationLaunchApp $didNotificationLaunchApp');
    if (didNotificationLaunchApp){
      setState(() {
        homepage = WakeupChart();
      });
    }
  }

  @override
  void initState() {
    initNotificationService();
    super.initState();
  }

  final navKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navKey,
      title: 'Alarm ',
      theme: ThemeData(

        primarySwatch: Colors.blue,
      ),
      home: homepage,
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  TimeOfDay? selectedTime;
  DateTime clockDisplay = DateTime.now();
  bool changeTime = false;

  getSavedTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? savedTimeMiliSec = prefs.getInt('latest alarm');
    if (savedTimeMiliSec != null){
      setState(() {
        clockDisplay = DateTime.fromMillisecondsSinceEpoch(savedTimeMiliSec);
        changeTime = true;
      });
    }
  }

  @override
  void initState() {
    getSavedTime();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

  double width = MediaQuery.of(context).size.width;
  double height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(

        title: Text(widget.title),
      ),
      body:Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
        Text('Alarm for :',
          style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold),),
            SizedBox(height: height*0.1,),
            Builder(
              builder: (context) {
                if(selectedTime!=null) {
                  String padZeroHour = (selectedTime!.hour < 10) ? '0' : '';
                  String padZeroMinute = (selectedTime!.minute < 10) ? '0' : '';
                  return Text('$padZeroHour${selectedTime!.hour} : $padZeroMinute${selectedTime!.minute}',
                  style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold),);
                }
                return Text('__ : __',
                  style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold),);
              }
            ),
            SizedBox(height: height*0.1,),
            Builder(
              builder: (BuildContext context) {
                if (changeTime){
                  changeTime = false;
                  return FlutterAnalogClock(
                    key: Key('$clockDisplay'),
                    dateTime: clockDisplay,
                    dialPlateColor: Colors.white,
                    hourHandColor: Colors.blue,
                    minuteHandColor: Colors.blue,
                    secondHandColor: Colors.blue,
                    numberColor: Colors.blue,
                    borderColor: Colors.blue,
                    tickColor: Colors.blue,
                    centerPointColor: Colors.blue,
                    showBorder: true,
                    showTicks: true,
                    showMinuteHand: true,
                    showSecondHand: false,
                    showNumber: true,
                    borderWidth: 12.0,
                    hourNumberScale: 1.0,
                    hourNumbers: ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12'],
                    isLive: true,
                    width: width*0.8,
                    height: width*0.8,
                    decoration: const BoxDecoration(),
                    runclock: false,
                  );
                }
                return FlutterAnalogClock(
                  dateTime: clockDisplay,
                  dialPlateColor: Colors.white,
                  hourHandColor: Colors.blue,
                  minuteHandColor: Colors.blue,
                  secondHandColor: Colors.blue,
                  numberColor: Colors.blue,
                  borderColor: Colors.blue,
                  tickColor: Colors.blue,
                  centerPointColor: Colors.blue,
                  showBorder: true,
                  showTicks: true,
                  showMinuteHand: true,
                  showSecondHand: false,
                  showNumber: true,
                  borderWidth: 12.0,
                  hourNumberScale: 1.0,
                  hourNumbers: ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12'],
                  isLive: true,
                  width: 300.0,
                  height: 300.0,
                  decoration: const BoxDecoration(),
                  runclock: false,
                );
              },
            ),
            Spacer(),
            SizedBox(
              width: width*0.8,
              height: width*0.15,
              child: ElevatedButton(onPressed: () async {
                var _selectedTime =   await showTimePicker(context: context, initialTime: TimeOfDay.now());
                DateTime now = DateTime.now();
                setState(() {
                  selectedTime = _selectedTime;
                  clockDisplay = DateTime(now.year,now.month,now.day,selectedTime!.hour,selectedTime!.minute);
                  changeTime = true;
                });
                Duration difference = clockDisplay.difference(now);
                int alarmDay = (difference.isNegative) ?  (now.day + 1) : now.day;
                tz.TZDateTime tzAlarm = tz.TZDateTime.local(now.year,now.month,alarmDay,selectedTime!.hour,selectedTime!.minute);
                NotificationService().scheduleNotifications(scheduledTime: tzAlarm);
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.setInt('latest alarm', clockDisplay.millisecondsSinceEpoch);
              },
                  child: Text("Set Time"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
