import 'package:clock_app/alarm_helper.dart';
import 'package:clock_app/models/alarm_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:clock_app/models/mission.dart';
import 'package:clock_app/models/sound.dart';
import 'dart:convert';
import 'package:flutter_picker/flutter_picker.dart';

// noti click to mission p
import 'package:rxdart/rxdart.dart';
import 'cancel_page.dart';

import '../main.dart';


class AlarmPage extends StatefulWidget {
  @override
  _AlarmPageState createState() => _AlarmPageState();
}

class _AlarmPageState extends State<AlarmPage> {
  DateTime _alarmTime;
  String _alarmTimeString;
  AlarmHelper _alarmHelper = AlarmHelper();
  Future<List<AlarmInfo>> _alarms;
  List<AlarmInfo> _currentAlarms;

  TextEditingController titleController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _missiontext;
  String _alarmSound = '';

  // noti click to mission p
  final _notifications = FlutterLocalNotificationsPlugin();
  final onNotifications = BehaviorSubject<String>();

  // update/edit
  bool editting = false;
  TextEditingController _editingController;

  bool status = false;


  @override
  void initState() {
    _alarmTime = DateTime.now();
    _alarmHelper.initializeDatabase().then((value) {
      print('------database intialized');
      loadAlarms();
    });
    final android = AndroidInitializationSettings('@mipmap/ic_launcher');
    final ios = IOSInitializationSettings();
    final settings = InitializationSettings(android, ios);


    _notifications.initialize(
      settings,
      onSelectNotification: (payload) async{
        onNotifications.add(payload);
      },
    );

    super.initState();

    // noti click to mission p
    init();
    listenNotifications();

  }


  void onListenNotification(String payload){
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => cancel_page(payload: payload)
    ));
  }

   //noti click to mission p
   void listenNotifications(){
     //onNotifications.stream.listen(onClickedNotification);
     onNotifications.stream.listen(onListenNotification);
   }

  void loadAlarms() {
    _alarms = _alarmHelper.getAlarms();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 64),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Alarm',
            style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.blueGrey[100],
                fontSize: 36),
          ),
          Expanded(
            child: FutureBuilder<List<AlarmInfo>>(
              future: _alarms,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  _currentAlarms = snapshot.data;
                  return ListView(
                    children: snapshot.data.map<Widget>((alarm) {
                      var alarmTime =
                      DateFormat('hh:mm aa').format(alarm.alarmDateTime);

                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 0, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Text(
                                      alarmTime,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                Icon(
                                  Icons.label,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  alarm.title,
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                IconButton(
                                    icon: Icon(Icons.delete),
                                    color: Colors.white,
                                    iconSize: 25,
                                    onPressed: () {
                                      deleteAlarm(alarm.id);
                                    }),
                                SizedBox(width: 50),
                                IconButton(
                                    icon: Icon(Icons.edit),
                                    color: Colors.white,
                                    iconSize: 20,
                                    onPressed: () {
                                      // update/edit
                                      _editingController = TextEditingController(text: alarm.title);
                                      _alarmTimeString =
                                          DateFormat('HH:mm').format(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, alarm.alarmDateTime.hour, alarm.alarmDateTime.minute));
                                          //DateFormat('HH:mm').format(DateTime.now());
                                      showModalBottomSheet(
                                        useRootNavigator: true,
                                        context: context,
                                        clipBehavior: Clip.antiAlias,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(24),
                                          ),
                                        ),
                                        builder: (context) {
                                          return StatefulBuilder(
                                            builder: (context, setModalState) {
                                              return Container(
                                                padding: const EdgeInsets.all(32),
                                                child: Column(
                                                  children: [
                                                    FlatButton(
                                                      onPressed: () async {
                                                        var selectedTime =
                                                        await showTimePicker(
                                                          context: context,
                                                          initialTime:
                                                              TimeOfDay(hour: alarm.alarmDateTime.hour, minute: alarm.alarmDateTime.minute),
                                                          //TimeOfDay.now(),
                                                        );
                                                        if (selectedTime != null) {
                                                          final now = DateTime.now();
                                                          var selectedDateTime =
                                                          DateTime(
                                                              now.year,
                                                              now.month,
                                                              now.day,
                                                              selectedTime.hour,
                                                              selectedTime
                                                                  .minute);
                                                          _alarmTime =
                                                              selectedDateTime;
                                                          setModalState(() {
                                                            _alarmTimeString =
                                                                DateFormat('HH:mm')
                                                                    .format(
                                                                    selectedDateTime);
                                                          });
                                                        }
                                                      },
                                                      child: Text(
                                                        _alarmTimeString,
                                                        style:
                                                        TextStyle(fontSize: 32),
                                                      ),
                                                    ),
                                                    ListTile(
                                                      title: TextField(
                                                        onSubmitted: (newValue){
                                                          setState(() {
                                                            _editingController..text = newValue;
                                                          });
                                                          print("new value: ");
                                                          print(_editingController.text);
                                                        },
                                                        autofocus: true,
                                                        controller: _editingController,
                                                        decoration: const InputDecoration(
                                                          border: UnderlineInputBorder(),
                                                          labelText: 'Edit alarm title',
                                                        ),
                                                      ),
                                                    ),
                                                    ListTile(
                                                      title: Text('Sound'),
                                                      trailing:Icon(Icons.arrow_forward_ios),
                                                      onTap: () {
                                                        showPickerSound(context, sound);
                                                      },
                                                    ),
                                                    ListTile(
                                                      title: Text('Mission'),
                                                      trailing: Icon(Icons.arrow_forward_ios),
                                                      onTap: () {
                                                        showPickerMission(context, mission);
                                                      },
                                                    ),
                                                    FloatingActionButton.extended(
                                                      onPressed: (){
                                                        editting = true;
                                                        onSaveAlarm(Text(_editingController.text), alarm.id);
                                                      },
                                                      icon: Icon(Icons.alarm),
                                                      label: Text('Save'),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          );
                                        },
                                      );

                                    }),
                              ],
                            ),

                            SizedBox(
                              height: 0.5,
                              child: Container(
                                color: Colors.white,
                              ),)
                          ],
                        ),
                      );
                    }).followedBy([
                      if (_currentAlarms.length < 20)
                        Container(
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.blueGrey[300],
                              borderRadius:
                              BorderRadius.all(Radius.circular(24)),
                            ),
                            child: FlatButton(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 16),
                              onPressed: () {
                                _alarmTimeString =
                                    DateFormat('HH:mm').format(DateTime.now());
                                showModalBottomSheet(
                                  useRootNavigator: true,
                                  context: context,
                                  clipBehavior: Clip.antiAlias,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(24),
                                    ),
                                  ),
                                  builder: (context) {
                                    return StatefulBuilder(
                                      builder: (context, setModalState) {
                                        return Container(
                                          padding: const EdgeInsets.all(32),
                                          child: Column(
                                            children: [
                                              FlatButton(
                                                onPressed: () async {
                                                  var selectedTime =
                                                  await showTimePicker(
                                                    context: context,
                                                    initialTime:
                                                    TimeOfDay.now(),
                                                  );
                                                  if (selectedTime != null) {
                                                    final now = DateTime.now();
                                                    var selectedDateTime =
                                                    DateTime(
                                                        now.year,
                                                        now.month,
                                                        now.day,
                                                        selectedTime.hour,
                                                        selectedTime
                                                            .minute);
                                                    _alarmTime =
                                                        selectedDateTime;
                                                    setModalState(() {
                                                      _alarmTimeString =
                                                          DateFormat('HH:mm')
                                                              .format(
                                                              selectedDateTime);
                                                    });
                                                  }
                                                },
                                                child: Text(
                                                  _alarmTimeString,
                                                  style:
                                                  TextStyle(fontSize: 32),
                                                ),
                                              ),
                                              ListTile(
                                                title: TextField(
                                                  controller: titleController,
                                                  decoration: const InputDecoration(
                                                    border: UnderlineInputBorder(),
                                                    labelText: 'Enter alarm title',
                                                  ),
                                                ),
                                              ),
                                              ListTile(
                                                title: Text('Sound'),
                                                trailing:Icon(Icons.arrow_forward_ios),
                                                onTap: () {
                                                  showPickerSound(context, sound);
                                                },
                                              ),
                                              ListTile(
                                                title: Text('Mission'),
                                                trailing: Icon(Icons.arrow_forward_ios),
                                                onTap: () {
                                                  showPickerMission(context, mission);
                                                },
                                              ),
                                              FloatingActionButton.extended(
                                                onPressed: (){

                                                  onSaveAlarm(Text(titleController.text), 0);
                                                },
                                                icon: Icon(Icons.alarm),
                                                label: Text('Save'),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                              child: Column(
                                children: <Widget>[
                                  Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                  // SizedBox(height: 8),
                                  Text(
                                    'Add Alarm',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      else
                        Center(
                            child: Text(
                              'Only 5 alarms allowed!',
                              style: TextStyle(color: Colors.white),
                            )),
                    ]).toList(),
                  );
                }
                return Center(
                  child: Text(
                    'Loading..',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void scheduleAlarm(
      DateTime scheduledNotificationDateTime, AlarmInfo alarmInfo, ) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'alarm_notif',
      'alarm_notif',
      'Channel for Alarm notification',
      icon: 'codex_logo',
      sound: RawResourceAndroidNotificationSound(alarmInfo.sound.split('.').first), // alarminfo add
      largeIcon: DrawableResourceAndroidBitmap('codex_logo'),
    );

    var iOSPlatformChannelSpecifics = IOSNotificationDetails(
        sound: alarmInfo.sound, // alarminfo add
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        );
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

    // noti click to mission p
    String mission = alarmInfo.mission;
    String sound = alarmInfo.sound;
    await flutterLocalNotificationsPlugin.schedule(0, alarmInfo.title, alarmInfo.mission,
        scheduledNotificationDateTime, platformChannelSpecifics, payload: '$mission,$sound');

  }

  // noti click to mission p
  void init({bool initScheduleed = false}) async {
    final android = AndroidInitializationSettings('@mipmap/ic_launcher');
    final ios = IOSInitializationSettings();
    final settings = InitializationSettings(android, ios);

    await _notifications.initialize(
      settings,
      onSelectNotification: (payload) async{
        onNotifications.add(payload);
      },
    );
  }

  // update/edit
  void onSaveAlarm(Text inputtitle, int id) {
    DateTime scheduleAlarmDateTime;
    if (_alarmTime.isAfter(DateTime.now()))
      scheduleAlarmDateTime = _alarmTime;
    else
      scheduleAlarmDateTime = _alarmTime.add(Duration(days: 1));

    // default title
    if(inputtitle.data.isEmpty)
      inputtitle = Text("Alarm");


    var alarmInfo;

    // update/edit
    if(editting == true){
      alarmInfo = AlarmInfo(
        alarmDateTime: scheduleAlarmDateTime,
        // set alarm title as user input
        id: id,
        title: inputtitle.data,
        mission: _missiontext,    // alarminfo add
        sound: _alarmSound,        // alarminfo add
      );
      _alarmHelper.edit(alarmInfo);
    }
    else {
      alarmInfo = AlarmInfo(
        alarmDateTime: scheduleAlarmDateTime,
        // set alarm title as user input
        title: inputtitle.data,
        mission: _missiontext,    // alarminfo add
        sound: _alarmSound,        // alarminfo add
      );

      _alarmHelper.insertAlarm(alarmInfo);
    }
    editting = false;
    scheduleAlarm(scheduleAlarmDateTime, alarmInfo);
    Navigator.pop(context);
    loadAlarms();
  }

  void deleteAlarm(int id) {
    _alarmHelper.delete(id);
    //unsubscribe for notification
    loadAlarms();
  }

  // edit alarm
  void editAlarm(AlarmInfo alarmInfo){
    _alarmHelper.edit(alarmInfo);
  }

  showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
  showPickerMission(BuildContext context, PickerData) {
    Picker(
        adapter: PickerDataAdapter<String>(
          pickerdata: JsonDecoder().convert(PickerData),
          isArray: true,
        ),
        hideHeader: true,
        selecteds: [0],
        title: Text("Please Select"),
        selectedTextStyle: TextStyle(color: Colors.blue),
        cancel: TextButton(
          onPressed: () {
            Navigator.pop(context);
          },),
        onConfirm: (Picker picker, List value) {
          print(value.toString());
          print(picker.getSelectedValues());
          _missiontext = picker.getSelectedValues().join("");
          if(_missiontext == 'None' || _missiontext == ''){
            _missiontext = null;
          }
        }).showDialog(context);
  }
  showPickerSound(BuildContext context, PickerData) {
    Picker(
        adapter: PickerDataAdapter<String>(
          pickerdata: JsonDecoder().convert(PickerData),
          isArray: true,
        ),
        hideHeader: true,
        selecteds: [0],
        title: Text("Please Select"),
        selectedTextStyle: TextStyle(color: Colors.blue),
        cancel: TextButton(
          onPressed: () {
            Navigator.pop(context);
          },),
        onConfirm: (Picker picker, List value) {
          print(value.toString());
          print(picker.getSelectedValues());
          _alarmSound = picker.getSelectedValues().join("");
          if(_alarmSound == ''){
            _alarmSound = '';
          }

        }).showDialog(context);
  }

  Future<void> cancelNotifications() async{
    await flutterLocalNotificationsPlugin.cancel(0);
  }


}


