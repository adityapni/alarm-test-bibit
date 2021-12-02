import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'main.dart';

class WakeupChart extends StatelessWidget {



  Stream<List<Duration>?> getAlarmTime() async *{
    DateTime openedTime = DateTime.now();
    List<Duration> alarmAnswerTimeList = [];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int alarmMilisec = prefs.getInt('latest alarm')?? 0;
    DateTime alarm = DateTime.fromMillisecondsSinceEpoch(alarmMilisec);
    print('alarm time $alarm');
    Duration difference = openedTime.difference(alarm);
    alarmAnswerTimeList.add(difference);


    //sort saved answer time according to alarm time
    int farFuture = DateTime(2100).millisecondsSinceEpoch;
    List<int> sortedKeys = prefs.getKeys().map((key) {
      print('key $key');
      if(key!= 'latest alarm'){
        return int.parse(key);
      }
      return farFuture;
    }).toList();
    sortedKeys.sort((b, a) => a.compareTo(b));
    print('sortedKeys $sortedKeys');

    //get answer time difference from shared preferences
    int numOfAlarms = 1;
    sortedKeys.forEach((key) {
      if ( key != farFuture && numOfAlarms < 8){
        int savedDifferenceMilisec = prefs.getInt('$key')?? 0;
        Duration savedDifference = Duration(milliseconds: savedDifferenceMilisec);
        alarmAnswerTimeList.add(savedDifference);
      }
      if (key != farFuture && numOfAlarms >= 8){
        prefs.remove('$key');
      }
      numOfAlarms++;
    });

    //save answer time to shared preferences
    print('alarm time ${alarm}');
    prefs.setInt('${alarm.millisecondsSinceEpoch}', difference.inMilliseconds);
    yield alarmAnswerTimeList;
  }

  final Color barBackgroundColor = const Color(0xff72d8bf);

  BarChartGroupData makeGroupData(
      int x,
      double y, {
        bool isTouched = false,
        Color barColor = Colors.white,
        double width = 22,
        List<int> showTooltips = const [],
      }) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
            y: y,
            colors: isTouched ? [Colors.yellow] : [barColor],
            width: width,
            borderSide: isTouched
                ? BorderSide(color: Colors.yellow, width: 1)
                : const BorderSide(color: Colors.white, width: 0),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              y: 20,
              colors: [barBackgroundColor],)
        ),
      ]
    );
  }

  List<BarChartGroupData> createChart(List<Duration> alarmAnswerTimeList){
    int x = 1;
    List<BarChartGroupData> barList = alarmAnswerTimeList.map((alarmAnswerTime) {
      BarChartGroupData bcGroupData = makeGroupData(
          x,
          alarmAnswerTime.inSeconds.toDouble(),
          barColor: Colors.blue);
      x++;
      return bcGroupData;
    }).toList();
    return barList;
  }

  @override
  Widget build(BuildContext context) {

    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Text('Last 7 alarm answer time',style: TextStyle(fontSize: 30)),
            Expanded(
              child: StreamBuilder<List<Duration>?>(
                stream: getAlarmTime(),
                builder: (context, snapshot) {
                  if (snapshot.hasData){
                    if (snapshot.data!.isNotEmpty){
                      List<Text> textAlarmTimeList = snapshot.data!.map((difference) => Text('$difference')).toList();
                      return Padding(
                        padding: EdgeInsets.all(16),
                        child: BarChart(
                          BarChartData(
                            backgroundColor: barBackgroundColor,
                            barGroups: createChart(snapshot.data?? []),
                          )
                        ),
                      );
                    }
                    return Text('No alarm yet');
                  }
                  return Text('No alarm yet');
                }
              ),
            ),
            SizedBox(
              width: width * 0.8,
              height: width * 0.15,
              child: ElevatedButton(onPressed: (){
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyHomePage(title: 'Alarm App',) ));
              }, child: Text('OK')),
            )
          ],
        ),
      ),
    );
  }
}
