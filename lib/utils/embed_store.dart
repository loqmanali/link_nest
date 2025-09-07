import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class EmbedStore {
  static const String _key = 'embed_urls_by_post_id';

  static Future<Map<String, String>> _readAll() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_key);
    if (jsonStr == null || jsonStr.isEmpty) return {};
    try {
      final map = json.decode(jsonStr) as Map<String, dynamic>;
      return map.map((k, v) => MapEntry(k, v.toString()));
    } catch (_) {
      return {};
    }
  }

  static Future<void> setEmbedUrl(String postId, String embedUrl) async {
    if (postId.isEmpty || embedUrl.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final all = await _readAll();
    all[postId] = embedUrl;
    await prefs.setString(_key, json.encode(all));
  }

  static Future<String?> getEmbedUrl(String postId) async {
    final all = await _readAll();
    return all[postId];
  }

  static Future<void> remove(String postId) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await _readAll();
    all.remove(postId);
    await prefs.setString(_key, json.encode(all));
  }
}
