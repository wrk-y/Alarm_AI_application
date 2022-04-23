import 'package:clock_app/enums.dart';
// import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';

class MenuInfo extends ChangeNotifier {
  MenuType menuType;
  String title;
  IconData icon;

  MenuInfo(this.menuType, {this.title, this.icon});

  updateMenu(MenuInfo menuInfo) {
    this.menuType = menuInfo.menuType;
    this.title = menuInfo.title;
    this.icon = menuInfo.icon;

//Important
    notifyListeners();
  }
}