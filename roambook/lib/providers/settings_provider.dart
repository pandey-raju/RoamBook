import 'package:flutter/foundation.dart';

abstract class SettingsProvider with ChangeNotifier {
  bool get isDarkMode;
  bool get isNotificationsEnabled;
  String get language;

  Future<void> toggleDarkMode();
  Future<void> toggleNotifications();
  Future<void> setLanguage(String languageCode);
  Future<void> clearCache();
  Future<void> exportData();
  Future<void> importData();
} 