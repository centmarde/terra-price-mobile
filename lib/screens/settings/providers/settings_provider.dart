import 'package:flutter/material.dart';

class SettingsProvider extends ChangeNotifier {
  bool isDarkMode = false;
  bool notificationsEnabled = true;
  bool dataSyncEnabled = true;

  void toggleDarkMode(bool value) {
    isDarkMode = value;
    notifyListeners();
  }

  void toggleNotifications(bool value) {
    notificationsEnabled = value;
    notifyListeners();
  }

  void toggleDataSync(bool value) {
    dataSyncEnabled = value;
    notifyListeners();
  }
}
