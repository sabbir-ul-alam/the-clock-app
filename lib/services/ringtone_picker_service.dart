import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RingtonePickerService {
  static const MethodChannel _channel = MethodChannel('ringtone_picker');

  static Future<List<Map<String, String>>> getSystemRingtones() async {
    print("before invokign channel");
    final List result = await _channel.invokeMethod('getSystemRingtones');
    print("After invoking channel ${result}");
    return result
        .map<Map<String, String>>((item) => Map<String, String>.from(item))
        .toList();
  }

  static Future<void> saveLastSelectedTone(String name, String uri) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastToneName', name);
    await prefs.setString('lastToneUri', uri);
  }

  static Future<Map<String, String>?> getLastSelectedTone() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('lastToneName');
    final uri = prefs.getString('lastToneUri');
    if (name != null && uri != null) {
      return {'name': name, 'uri': uri};
    }
    return null;
  }
}
