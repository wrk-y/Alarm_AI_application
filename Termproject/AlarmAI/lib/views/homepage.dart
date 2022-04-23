import 'package:alan_voice/alan_voice.dart';
import 'package:clock_app/data.dart';
import 'package:clock_app/enums.dart';
import 'package:clock_app/models/menu_info.dart';
import 'package:clock_app/views/alarm_page.dart';
import 'package:clock_app/views/cancel_page.dart';
import 'package:clock_app/views/clock_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();

}

class _HomePageState extends State<HomePage> {

  _HomePageState() {
    _initAlanButton();
    this.ca;
  }

  final cancel_page ca = new cancel_page();

  void _initAlanButton() {
    AlanVoice.addButton(
        "bac9851d8b864d5a7ee4059ad5b872082e956eca572e1d8b807a3e2338fdd0dc/stage"
    );

    AlanVoice.onCommand.add((command) => _handleCommand(command.data));

    AlanVoice.onEvent.add((event) {
      debugPrint("got new event ${event.data.toString()}");
    });

    AlanVoice.onButtonState.add((state) {
      debugPrint("got new button state ${state.name}");
    });
  }

  void _handleCommand(Map<String, dynamic> command) {
    debugPrint("got new command ${command}");

    switch (command["command"]) {
      case "pass":
        print('OK, stop alarm');
        ca.pauseMusic();
        Navigator.of(context).popUntil((route) => route.isFirst);
        break;
      default:
        print('No, try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[700],
      body: Row(
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: menuItems
                .map((currentMenuInfo) => buildMenuButton(currentMenuInfo))
                .toList(),
          ),
          VerticalDivider(
            color: Colors.white54,
            width: 1,
          ),
          Expanded(
            child: Consumer<MenuInfo>(
              builder: (BuildContext context, MenuInfo value, Widget child) {
                if (value.menuType == MenuType.clock)
                  return ClockPage();
                else if (value.menuType == MenuType.alarm)
                  return AlarmPage();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMenuButton(MenuInfo currentMenuInfo) {
    return Consumer<MenuInfo>(
      builder: (BuildContext context, MenuInfo value, Widget child) {
        return FlatButton(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 0),
          color: currentMenuInfo.menuType == value.menuType
              ? Colors.blueGrey[400]
              : Colors.transparent,
          onPressed: () {
            var menuInfo = Provider.of<MenuInfo>(context, listen: false);
            menuInfo.updateMenu(currentMenuInfo);
          },
          child: Column(
            children: <Widget>[
              Icon(
                currentMenuInfo.icon,
                color: Colors.white,
                size: 50,
              ),
              SizedBox(height: 16),
              Text(
                currentMenuInfo.title ?? '',
                style: TextStyle(color: Colors.white, fontSize: 14),
              )
            ],
          ),
        );
      },
    );
  }
}