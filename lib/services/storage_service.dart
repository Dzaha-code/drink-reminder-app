import 'package:shared_preferences/shared_preferences.dart';

import '../models/reminder.dart';

class StorageService {
  StorageService._();

  static SharedPreferences? _prefs;

  static const _keyReminders = 'reminders_v1';
  static const _keyNotificationsEnabled = 'settings_notifications_enabled_v1';
  static const _keyDefaultMessage = 'settings_default_message_v1';
  static const _keyDefaultSound = 'settings_default_sound_v1';

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static List<Reminder> loadReminders() {
    final raw = _prefs?.getStringList(_keyReminders) ?? <String>[];
    return raw.map((e) => Reminder.fromJson(e)).toList();
  }

  static Future<void> saveReminders(List<Reminder> reminders) async {
    final raw = reminders.map((r) => r.toJson()).toList();
    await _prefs?.setStringList(_keyReminders, raw);
  }

  // Settings helpers
  static bool notificationsEnabled() {
    return _prefs?.getBool(_keyNotificationsEnabled) ?? true;
  }

  static Future<void> setNotificationsEnabled(bool enabled) async {
    await _prefs?.setBool(_keyNotificationsEnabled, enabled);
  }

  static String defaultMessage() {
    return _prefs?.getString(_keyDefaultMessage) ?? 'Waktunya minum';
  }

  static Future<void> setDefaultMessage(String message) async {
    await _prefs?.setString(_keyDefaultMessage, message);
  }

  static String defaultSound() {
    // Name without extension for Android (raw resource), and filename for iOS (e.g. sound.caf)
    return _prefs?.getString(_keyDefaultSound) ?? '';
  }

  static Future<void> setDefaultSound(String sound) async {
    await _prefs?.setString(_keyDefaultSound, sound);
  }
}
