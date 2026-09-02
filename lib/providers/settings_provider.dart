import 'dart:math';

import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../data/models/app_usage_model.dart';
import '../data/repositories/settings_repository.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsRepository _repository = SettingsRepository();

  UserSettingsModel _settings = UserSettingsModel();
  bool _isLoading = true;

  UserSettingsModel get settings => _settings;
  bool get isLoading => _isLoading;

  ThemeSpec get themeSpec => AppTheme.specById(_settings.themeType);
  ThemeData get themeData {
    var base = themeSpec.data;
    if (_settings.backgroundPattern != 'none') {
      base = base.copyWith(scaffoldBackgroundColor: Colors.transparent);
    }
    if (_settings.buttonStyle == 'glass' || _settings.buttonStyle == 'liquid_glass') {
      final isLiquid = _settings.buttonStyle == 'liquid_glass';
      final accent = base.colorScheme.primary;
      final glassFill = accent.withOpacity(isLiquid ? 0.22 : 0.14);
      final glassRim = BorderSide(color: Colors.white.withOpacity(isLiquid ? 0.5 : 0.28), width: 0.7);
      base = base.copyWith(
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: glassFill,
            foregroundColor: base.colorScheme.onSurface,
            elevation: isLiquid ? 10 : 0,
            shadowColor: accent.withOpacity(0.45),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28), side: glassRim),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            backgroundColor: glassFill,
            foregroundColor: base.colorScheme.onSurface,
            side: glassRim,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: base.colorScheme.onSurface),
        ),
        // ChoiceChip/FilterChip/ActionChip (the Kalendar toggle, background
        // pattern picker, etc.) pull from ChipThemeData, not
        // ElevatedButtonTheme — without this they keep the default flat
        // black-outlined look even when glass mode is on.
        chipTheme: base.chipTheme.copyWith(
          backgroundColor: base.colorScheme.surface.withOpacity(isLiquid ? 0.35 : 0.5),
          selectedColor: glassFill,
          disabledColor: base.colorScheme.surface.withOpacity(0.2),
          labelStyle: TextStyle(color: base.colorScheme.onSurface),
          secondaryLabelStyle: TextStyle(color: base.colorScheme.onSurface),
          side: glassRim,
          shape: StadiumBorder(side: glassRim),
          elevation: isLiquid ? 4 : 0,
          pressElevation: isLiquid ? 6 : 1,
        ),
        cardTheme: base.cardTheme.copyWith(
          color: base.colorScheme.surface.withOpacity(isLiquid ? 0.5 : 0.75),
          elevation: isLiquid ? 6 : 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: Colors.white.withOpacity(0.18), width: 0.6),
          ),
        ),
      );
    }
    return base;
  }

  Future<void> load() async {
    _settings = await _repository.getSettings();
    if (_settings.deviceId.isEmpty) {
      _settings = _settings.copyWith(deviceId: _generateDeviceId());
      await _repository.saveSettings(_settings);
    }
    _isLoading = false;
    notifyListeners();
  }

  String _generateDeviceId() {
    final rand = Random.secure();
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(16, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  Future<void> setFamilyRole(String role) async {
    _settings = _settings.copyWith(familyRole: role);
    notifyListeners();
    await _repository.saveSettings(_settings);
  }

  Future<void> setLinkedChild(String? childDeviceId) async {
    _settings = _settings.copyWith(linkedChildDeviceId: childDeviceId);
    notifyListeners();
    await _repository.saveSettings(_settings);
  }

  Future<void> setChildDisplayName(String name) async {
    _settings = _settings.copyWith(childDisplayName: name);
    notifyListeners();
    await _repository.saveSettings(_settings);
  }

  Future<void> setButtonStyle(String style) async {
    _settings = _settings.copyWith(buttonStyle: style);
    notifyListeners();
    await _repository.saveSettings(_settings);
  }

  Future<void> setVisualizationMode(String mode) async {
    _settings = _settings.copyWith(visualizationMode: mode);
    notifyListeners();
    await _repository.saveSettings(_settings);
  }

  Future<void> setLocale(String localeCode) async {
    _settings = _settings.copyWith(locale: localeCode);
    notifyListeners();
    await _repository.saveSettings(_settings);
  }

  Future<void> setThemeId(String themeId) async {
    _settings = _settings.copyWith(themeType: themeId);
    notifyListeners();
    await _repository.saveSettings(_settings);
  }

  Future<void> setClockStyle(String style) async {
    _settings = _settings.copyWith(clockStyle: style);
    notifyListeners();
    await _repository.saveSettings(_settings);
  }

  Future<void> setTimerStyle(String style) async {
    _settings = _settings.copyWith(timerStyle: style);
    notifyListeners();
    await _repository.saveSettings(_settings);
  }

  Future<void> setCalendarStyle(String style) async {
    _settings = _settings.copyWith(calendarStyle: style);
    notifyListeners();
    await _repository.saveSettings(_settings);
  }

  Future<void> setBackgroundPattern(String pattern) async {
    _settings = _settings.copyWith(backgroundPattern: pattern);
    notifyListeners();
    await _repository.saveSettings(_settings);
  }

  Future<void> markOnboardingSeen() async {
    _settings = _settings.copyWith(hasSeenOnboarding: true);
    notifyListeners();
    await _repository.saveSettings(_settings);
  }

  Future<void> setFontScale(double scale) async {
    _settings = _settings.copyWith(fontScale: scale);
    notifyListeners();
    await _repository.saveSettings(_settings);
  }

  Future<void> setSleepWindow(String start, String end) async {
    _settings = _settings.copyWith(sleepStartTime: start, sleepEndTime: end);
    notifyListeners();
    await _repository.saveSettings(_settings);
  }

  Future<void> setDistractionLimit(int minutes) async {
    _settings = _settings.copyWith(dailyDistractionLimitMin: minutes);
    notifyListeners();
    await _repository.saveSettings(_settings);
  }

  Future<void> setAmbientSound(String? trackId) async {
    _settings = _settings.copyWith(ambientSound: trackId);
    notifyListeners();
    await _repository.saveSettings(_settings);
  }
}
