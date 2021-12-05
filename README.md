# Alarm App

This is a flutter alarm app created for bibit screening test.

## Dependencies

This app depends on these packages:

- [Local notifications](https://pub.dev/packages/flutter_local_notifications)
- [Shared preferences](https://pub.dev/packages/shared_preferences)
- [fl_chart](https://pub.dev/packages/fl_chart)

Run these commands to install:

```bash
flutter pub add flutter_local_notifications
flutter pub add shared_preferences
flutter pub add fl_chart
```

## Usage

Clicking the button will cause a material time picker to appear. Use it to set alarm time. A notification will appear at time set. Clicking the notification will open a chart of how much time the user takes to turn off alarm.

- To hear the alarm, please enable sound in your device. 
- Since flutter_local_notifications may not work on Huawei and XiaoMi devices, this app may also don't work on those devices.
- Android only because I don't have iOS yet.

## Changes to default clock display

Previously if app is opened the clock will display current time. This causes misunderstanding that alarm time is moving despite it isn't.
This is changed so that the clock will display scheduled alarm time.


## Video Link
[gdrive](https://drive.google.com/folderview?id=1Ft8W1mLIN-faa65lRmKdSZSbxI0he1NH)

