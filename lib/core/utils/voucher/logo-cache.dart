import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:http/http.dart' as http;

class LogoCache {
  static final Map<String, Uint8List> _cache = {};

  static Future<Uint8List?> load(String? url) async {
    if (url == null || url.isEmpty) return null;
    final cached = _cache[url];
    if (cached != null) return cached;

    try {
      final res = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 4));
      if (res.statusCode != 200) return null;

      // ပုံကို 150px ထိ ချုံ့ (PDF မှာ 50x50 ပဲ ပြလို့ လုံလောက်)
      final codec = await ui.instantiateImageCodec(
        res.bodyBytes,
        targetWidth: 180,
      );
      final frame = await codec.getNextFrame();
      final data = await frame.image.toByteData(format: ui.ImageByteFormat.png);
      if (data == null) return null;

      final bytes = data.buffer.asUint8List();
      _cache[url] = bytes;
      return bytes;
    } catch (_) {
      return null;
    }
  }
}
