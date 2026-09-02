import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';
import 'app_translations.dart';

/// Looks up [key] in the current UI language (from SettingsProvider),
/// falling back to Uzbek and then the raw key if something's missing —
/// so a gap in one language's translation can never show a blank or
/// crash, just a slightly-wrong-language string in the worst case.
String appText(BuildContext context, String key) {
  final locale = context.watch<SettingsProvider>().settings.locale;
  final table = kAppTranslations[locale] ?? kAppTranslations['uz']!;
  return table[key] ?? kAppTranslations['uz']?[key] ?? key;
}
