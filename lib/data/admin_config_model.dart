/// A single "what's new" / announcement card.
class Announcement {
  final String title;
  final String body;
  final String? date;

  Announcement({required this.title, required this.body, this.date});

  factory Announcement.fromJson(Map<String, dynamic> json) => Announcement(
        title: json['title'] as String? ?? '',
        body: json['body'] as String? ?? '',
        date: json['date'] as String?,
      );
}

/// One of "our other apps" promoted in the News screen.
class PromotedApp {
  final String name;
  final String description;
  final String url;
  final String? iconUrl;

  PromotedApp({required this.name, required this.description, required this.url, this.iconUrl});

  factory PromotedApp.fromJson(Map<String, dynamic> json) => PromotedApp(
        name: json['name'] as String? ?? '',
        description: json['description'] as String? ?? '',
        url: json['url'] as String? ?? '',
        iconUrl: json['icon_url'] as String?,
      );
}

/// Contact links (Telegram, email, etc).
class ContactLink {
  final String label;
  final String url;
  ContactLink({required this.label, required this.url});

  factory ContactLink.fromJson(Map<String, dynamic> json) => ContactLink(
        label: json['label'] as String? ?? '',
        url: json['url'] as String? ?? '',
      );
}

/// The full remote-fetched admin config.
class AdminConfig {
  final List<Announcement> announcements;
  final List<PromotedApp> apps;
  final List<ContactLink> contacts;
  final String? promoBannerText;

  AdminConfig({
    required this.announcements,
    required this.apps,
    required this.contacts,
    this.promoBannerText,
  });

  factory AdminConfig.fromJson(Map<String, dynamic> json) => AdminConfig(
        announcements: (json['announcements'] as List<dynamic>? ?? [])
            .map((e) => Announcement.fromJson(e as Map<String, dynamic>))
            .toList(),
        apps: (json['apps'] as List<dynamic>? ?? [])
            .map((e) => PromotedApp.fromJson(e as Map<String, dynamic>))
            .toList(),
        contacts: (json['contacts'] as List<dynamic>? ?? [])
            .map((e) => ContactLink.fromJson(e as Map<String, dynamic>))
            .toList(),
        promoBannerText: json['promo_banner_text'] as String?,
      );

  /// Shown when the remote config can't be fetched (offline, no config
  /// hosted yet) — keeps the screen useful instead of empty.
  factory AdminConfig.fallback() => AdminConfig(
        announcements: [
          Announcement(
            title: 'Xush kelibsiz!',
            body: "Yangiliklar bu yerda ko'rinadi. Hozircha internetga ulanish yo'q "
                "yoki yangiliklar hali joylashtirilmagan.",
          ),
        ],
        apps: [],
        contacts: [],
      );
}
