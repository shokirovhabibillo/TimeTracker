import 'dart:convert';
import 'dart:io';

import '../data/admin_config_model.dart';

/// Fetches the admin-editable JSON config that powers the "News & Contact"
/// screen — announcements, promoted apps, and contact links.
///
/// This is the app's lightweight "admin panel": there's no separate web
/// dashboard or backend. Instead, the config lives as a plain JSON file
/// in the app's own GitHub repo (e.g. `admin_config.json` at the repo
/// root). To publish an update, edit that file on GitHub and commit —
/// the app fetches the latest version (via the raw.githubusercontent.com
/// URL) every time this screen opens, so changes show up immediately,
/// with no app-store release needed.
///
/// Expected JSON shape:
/// ```json
/// {
///   "promo_banner_text": "Yangi versiya chiqdi!",
///   "announcements": [
///     {"title": "...", "body": "...", "date": "2026-08-10"}
///   ],
///   "apps": [
///     {"name": "...", "description": "...", "url": "https://...", "icon_url": "https://..."}
///   ],
///   "contacts": [
///     {"label": "Telegram", "url": "https://t.me/..."}
///   ]
/// }
/// ```
class RemoteConfigService {
  /// Replace with the raw URL of your own `admin_config.json` once you've
  /// added it to the repo, e.g.:
  /// https://raw.githubusercontent.com/<username>/<repo>/main/admin_config.json
  static const String configUrl =
      'https://raw.githubusercontent.com/shokirovhabibillo/TimeTracker/main/admin_config.json';

  Future<AdminConfig> fetch() async {
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 6);
      final request = await client.getUrl(Uri.parse(configUrl));
      final response = await request.close().timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) {
        client.close();
        return AdminConfig.fallback();
      }
      final body = await response.transform(utf8.decoder).join();
      client.close();
      final json = jsonDecode(body) as Map<String, dynamic>;
      return AdminConfig.fromJson(json);
    } catch (_) {
      // Offline, config not published yet, or malformed JSON — fall back
      // gracefully rather than showing an error screen.
      return AdminConfig.fallback();
    }
  }
}
