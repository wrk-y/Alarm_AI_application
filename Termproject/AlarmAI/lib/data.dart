import 'package:clock_app/enums.dart';
import 'package:flutter/material.dart';
import 'models/menu_info.dart';

List<MenuInfo> menuItems = [
  MenuInfo(MenuType.clock,
      title: 'Clock', icon: Icons.access_time),
  MenuInfo(MenuType.alarm,
      title: 'Alarm', icon: Icons.alarm),
];
