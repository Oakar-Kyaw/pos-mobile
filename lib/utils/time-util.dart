// utils/timezone_util.dart
import 'package:flutter_timezone/flutter_timezone.dart';

class TimezoneUtil {
  static Future<String> getTimezone() async {
    final TimezoneInfo cached = await FlutterTimezone.getLocalTimezone();
    return cached.identifier;
    // → "Asia/Rangoon", "Asia/Bangkok", "America/New_York" etc.
  }
}
