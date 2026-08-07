import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

/// Persists admin-picked child photos across app restarts.
///
/// There's no upload endpoint yet, so a picked photo is just a path to a
/// file on this machine. Everything else in the demo (attendance, plans,
/// paid invoices) is in-memory and resets on restart, but a photo that
/// vanished would read as a bug rather than a demo reset — so this one
/// thing is written to disk. Swap for a real upload + `photo_url` once the
/// backend exists.
class DemoPhotoStore {
  DemoPhotoStore._();

  static const _prefix = 'demo_kid_photo_';

  static Future<void> save(String kidId, String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_prefix$kidId', path);
  }

  /// Stored photo paths by kid id, skipping any whose file has since been
  /// moved or deleted — a dangling path would render as a broken image.
  static Future<Map<String, String>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final result = <String, String>{};
    for (final key in prefs.getKeys()) {
      if (!key.startsWith(_prefix)) continue;
      final path = prefs.getString(key);
      if (path == null || !File(path).existsSync()) continue;
      result[key.substring(_prefix.length)] = path;
    }
    return result;
  }
}
