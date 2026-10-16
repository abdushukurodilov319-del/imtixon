import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AppStorage {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static List<Map<String, dynamic>> loadList(String key, List<Map<String, dynamic>> defaultValue) {
    try {
      final String? data = _prefs.getString(key);
      if (data == null) return defaultValue;
      final List<dynamic> decoded = jsonDecode(data);
      return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (e) {
      return defaultValue;
    }
  }

  static Future<void> saveList(String key, List<Map<String, dynamic>> list) async {
    try {
      await _prefs.setString(key, jsonEncode(list));
    } catch (e) {
      // Handle error
    }
  }
}
