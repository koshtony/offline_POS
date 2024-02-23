import 'package:shared_preferences/shared_preferences.dart';

class PrefHelper {
  static Future<bool> saveUserName(key, value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    return await prefs.setString(key, value);
  }

  static Future getValue(key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString(key);
  }

  static Future<void> delVal(key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.remove(key);
  }
}
